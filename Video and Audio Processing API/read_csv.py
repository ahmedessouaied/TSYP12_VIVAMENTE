import numpy as np


def load_labels(filename, col_labels=1, skip_header=True, delim=';'):
    """
    Reads column `col_labels` from a CSV file (arbitrary data type).

    Args:
        filename (str): CSV filename.
        col_labels (int): Index of the target column (indexing starts at 1, default: 1).
        skip_header (bool): Whether to skip the first line of the CSV file (default: True).
        delim (str): Delimiter used in the CSV file (default: ';').

    Returns:
        numpy.ndarray: Array of labels.
    """
    labels = []
    with open(filename, 'r', encoding='utf-8') as csv_file:
        if skip_header:
            next(csv_file)
        for line in csv_file:
            cols = line.split(delim)
            labels.append(cols[col_labels - 1].strip())
    return np.array(labels)


def load_features(filename, skip_header=True, skip_instname=True, delim=';', num_lines=0):
    """
    Reads a CSV file with numerical data (except for the first item if `skip_instname=True`).

    Args:
        filename (str): CSV filename.
        skip_header (bool): Whether to skip the first line of the CSV file (default: True).
        skip_instname (bool): Whether to skip the first column in the file (default: True).
        delim (str): Delimiter used in the CSV file (default: ';').
        num_lines (int): Number of lines in the file. If known, speeds up processing (default: 0).

    Returns:
        numpy.ndarray: Array of features (float).
    """
    if num_lines == 0:
        num_lines = get_num_lines(filename, skip_header)

    num_columns = get_num_columns(filename, skip_header, skip_instname, delim)
    data = np.empty((num_lines, num_columns), dtype=float)

    with open(filename, 'r', encoding='utf-8') as csv_file:
        if skip_header:
            next(csv_file)
        for c, line in enumerate(csv_file):
            offset = 0
            if skip_instname:
                offset = line.find(delim) + 1
            data[c, :] = np.fromstring(line[offset:], dtype=float, sep=delim)

    return data


def get_num_lines(filename, skip_header):
    """
    Counts the number of lines in a file.

    Args:
        filename (str): Filename.
        skip_header (bool): Whether to skip the first line.

    Returns:
        int: Number of lines.
    """
    with open(filename, 'r', encoding='utf-8') as csv_file:
        if skip_header:
            next(csv_file)
        return sum(1 for _ in csv_file)


def get_num_columns(filename, skip_header, skip_instname, delim):
    """
    Determines the number of columns in a file.

    Args:
        filename (str): Filename.
        skip_header (bool): Whether to skip the first line.
        skip_instname (bool): Whether to skip the first column.
        delim (str): Delimiter used in the file.

    Returns:
        int: Number of columns.
    """
    with open(filename, 'r', encoding='utf-8') as csv_file:
        if skip_header:
            next(csv_file)
        line = csv_file.readline()
        offset = 0
        if skip_instname:
            offset = line.find(delim) + 1
        cols = np.fromstring(line[offset:], dtype=float, sep=delim)
    return len(cols)
