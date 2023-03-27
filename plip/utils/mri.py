#!/usr/bin/python3
import numpy as np
import nibabel as nib
from pathlib import Path, PosixPath


def find_image(directory, filename):
    """ Helper function if extension is unknown """
    image = list()
    for ext in [".nii.gz", ".nii", ".hdr"]:
        filepath = Path(directory) / (filename + ext)
        if filepath.is_file():
            image.append(filepath)

    if len(image) == 0:
        return False
    elif len(image) != 1:
        raise Exception(f'Multiple images detected in directory "{directory}"')
    else:
        return image.pop()


def create_image(data, like):
    affine = like.affine
    header = like.header
    return nib.Nifti1Image(data, affine=affine, header=header)


def load_image(filepath, closest_canonical=False):
    image = nib.load(str(filepath))
    if closest_canonical:
        return nib.as_closest_canonical(image)
    return image


def load_data(image):
    if isinstance(image, (str, PosixPath)):
        image = load_image(image)
    return image.get_fdata()


def save_image(image, filepath):
    nib.save(image, str(filepath))


def _mse(data1, data2):
    return np.mean(np.square(data1 - data2))


def img_diff(file1, file2):
    img1, img2 = load_image(file1), load_image(file2)
    af1, af2 = img1.affine, img2.affine
    if img1.shape != img2.shape:
        return f"Shape's do not match.\n{img1.shape}\t{img2.shape}"
    if not (af1 == af2).all():
        return f"Affine's do not match.\nAffine1\n{af1}\n\nAffine2\n{af2}"
    d1, d2 = load_data(img1), load_data(img2)
    return _mse(d1, d2)
