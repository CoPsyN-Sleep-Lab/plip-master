#!/usr/bin/python3
import os
import sys
import shutil
import plip.utils.os as plipos
from pathlib import Path

script_dir = Path(__file__).absolute().parent
image_exts = [
    '.nii.gz',
    '.nii',
    '.hdr',
]


def _potential_filenames(fn):
    '''
    This function returns the potential filenames that fn might refer to.
    Since it's conventional when calling FSL to omit file extensions for image
    files, we try adding them here.
    >>> _potential_filenames('hi')
    ['hi.nii.gz', 'hi.nii', 'hi.hdr', 'hi']
    >>> _potential_filenames('hi.nii')
    ['hi.nii.gz', 'hi.nii', 'hi.hdr']
    >>> _potential_filenames('somedir/../image')
    ['somedir/../image.nii.gz', 'somedir/../image.nii', 'somedir/../image.hdr', 'somedir/../image']
    >>> _potential_filenames('dt.csv')
    ['dt.csv']
    '''
    fn_ext = None
    truncated_fn = fn
    for image_ext in image_exts:
        if fn.endswith(image_ext):
            fn_ext = image_ext
            truncated_fn = fn[:-len(fn_ext)]
    # if the filename has no extension or has an imaging extension, we try all
    # possible imaging extensions.
    no_ext = '.' not in Path(fn).name
    if no_ext or fn_ext is not None:
        vals = [
            '{}{}'.format(truncated_fn, ext)
            for ext in image_exts
        ]
        if no_ext:
            vals.append(fn)
        return vals
    else:
        return [fn]


def prepare_arguments(args):
    '''
    >>> os.chdir(script_dir)
    >>> args, docker = prepare_arguments(['hi', 'main.sh', '../fsl-in-docker', '--hi=main.sh', '-o', 'out1/hi.sh', '--out=out2/hi.sh'])
    >>> args
    ['hi', '/vols/0/main.sh', '/vols/1/fsl-in-docker', '--hi=/vols/0/main.sh', '-o', '/vols/2/hi.sh', '--out=/vols/3/hi.sh']
    >>> [d.replace(script_dir, '$PWD').replace(Path(script_dir + '/..').absolute(), '$PWD/..') for d in docker]
    ['-B', '$PWD/..:/vols/1', '-B', '$PWD:/vols/0', '-B', '$PWD/out1:/vols/2', '-B', '$PWD/out2:/vols/3']
    >>> prepare_arguments(['hi', '-omat', 'random.sh'])[0]
    ['hi', '-omat', '/vols/0/random.sh']
    >>> prepare_arguments(['hi', 'hi/random.sh'])[0]
    ['hi', '/vols/0/random.sh']
    '''
    final_args = []
    docker_vols = {}
    for argidx, arg in enumerate(args):
        # It's the command, so simply pass it along.
        if argidx == 0:
            final_args.append(arg)
            continue
        # A double-hyphen argument has a value that we should try parsing as a file.
        elif arg.startswith('--'):
            # then we need to parse it out
            argkey, argval = arg.split('=')
            is_output = argkey == '--out'
        # Single hyphen arguments should be passed on
        # HACK putting this check after the check for -- so it won't capture those cases.
        elif arg.startswith('-'):
            final_args.append(arg)
            continue
        else:
            argkey, argval = None, arg
            is_output = args[argidx-1] in ('-o', '-omat')

        # When we have an output argument or if the file exists, we try to rewrite the directory.
        if is_output or '/' in argval or any(Path(fn).exists() for fn in _potential_filenames(argval)):
            while Path(argval).is_symlink():
                argval = os.readlink(argval)
            orig_dirname = Path(argval).parent
            dirname = orig_dirname.absolute()
            if dirname not in docker_vols:
                docker_vols[dirname] = '/vols/{}'.format(len(docker_vols))
            # We refer to orig_dirname since files without a dir have an empty dirname that we replace.
            argval = Path(docker_vols[dirname]) / os.path.relpath(argval, orig_dirname)

        # Build our argument back up.
        if argkey is None:
            arg = argval
        else:
            arg = '{}={}'.format(argkey, argval)
        final_args.append(arg)

    return final_args, [
        arg
        for source, dest in sorted(docker_vols.items())
        for arg in ['-B', '{}:{}'.format(source, dest)]
    ]


def fsl_in_docker(*args):
    args = [str(e) for e in args]
    if args[0] == 'test':
        import doctest
        doctest.testmod()
        print('Tests completed.')
        sys.exit(0)

    if shutil.which("singularity"):
        use_docker = False
        if "FSL_IN_DOCKER_SIMG" in os.environ:
            docker_image = os.environ["FSL_IN_DOCKER_SIMG"]
        else:
            docker_image = "docker://williamspanlab/fsl-in-docker:1.0.2"
    elif shutil.which("docker"):
        use_docker = True
        docker_image = 'williamspanlab/fsl-in-docker:1.0.2'
    else:
        raise Exception("Singularity and docker are not in path")

    final_args, docker_args = prepare_arguments(args)

    envs = []
    singularity_env = {}
    for calling_env_var in ['FSLOUTPUTTYPE']:
        value = os.getenv(calling_env_var)
        # HACK we have the convention that a calling environment's env var is
        # prefixed with SET_ for use when setting the container's env var.
        # This helps avoid issues with colliding variables, per this github
        # issue https://github.com/sylabs/singularity/issues/2451
        container_env_var = 'SET_'+calling_env_var
        if value is not None:
            envs += ['--env', '{}={}'.format(container_env_var, value)]
            singularity_env['SINGULARITYENV_'+container_env_var] = value

    if use_docker:
        cmd = ['docker', 'run', '--rm'] + envs + [
            '-v' if arg == '-B' else arg
            for arg in docker_args
        ] + [docker_image, '/main.sh'] + final_args
    else:
        # HACK this is the command for singularity
        cmd = ['singularity', 'exec'] + docker_args + [docker_image, "/main.sh"] + final_args
    plipos.run_shell(cmd, env=dict(os.environ, **singularity_env))


if __name__ == '__main__':
    args = sys.argv[1:]
    fsl_in_docker(args)
