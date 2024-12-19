import librosa
import numpy as np
import pandas as pd

def process_mfcc(audio_path):
    # Load the audio file
    y, sr = librosa.load(audio_path, sr=None)
    
    # Extract MFCC features
    mfccs = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=13)

    # Extract delta (first-order derivatives)
    mfccs_delta = librosa.feature.delta(mfccs)

    # Extract delta-delta (second-order derivatives)
    mfccs_delta2 = librosa.feature.delta(mfccs, order=2)

     # Combine MFCCs, delta, and delta-delta into a single 40-dimensional array
    combined_features = np.vstack((mfccs, mfccs_delta, mfccs_delta2))

    # Transpose to get time x 40 shape
    combined_features = combined_features.T

    # Convert to DataFrame
    mfcc_df = pd.DataFrame(combined_features)
    return mfcc_df
    