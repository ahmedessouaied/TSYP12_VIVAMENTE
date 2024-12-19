import os
import numpy as np

def save_features(filename, data, append=False, instname='', header='', delim=';', precision=8):
    """
    Write a CSV file.

    Args:
        filename (str): CSV filename.
        data (numpy.ndarray): Data given as a numpy array.
        append (bool): If True, appends to the file. Otherwise, overwrites the file.
        instname (str): If a non-empty string is given, it is added as the first element in each row.
        header (str): If a non-empty string is given, writes the header line as a string.
        delim (str): Delimiter used in the CSV file (default: ';').
        precision (int): Floating point precision (default: 8).
    """
    mode = 'w'
    if append:
        mode = 'a'
        if os.path.isfile(filename):
            header = ''  # Do not write header if the file already exists and is being appended

    with open(filename, mode, encoding='utf-8') as csv_file:
        if header:
            csv_file.write(header + '\n')

        for row in data:
            if instname:
                csv_file.write(f"'{instname}'{delim}")
            row_str = np.array2string(
                row,
                max_line_width=100000,
                precision=precision,
                separator=delim,
                formatter={'float_kind': lambda x: f"{x:.{precision}g}"}
            )[1:-1].replace(' ', '')  # Remove brackets and whitespace
            csv_file.write(row_str + '\n')
