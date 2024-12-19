import os
import re
import pandas as pd

class DataMerger:
    def __init__(self, base_path):
        self.base_path = base_path
        self.pose_pattern = "_CLNF_pose.txt"
        self.gaze_pattern = "_CLNF_gaze.txt"
        self.features_pattern = "_CLNF_features.txt"
        self.au_pattern = "_CLNF_AUs.txt"
        self.covarep_pattern = "_COVAREP.csv"
        self.formant_pattern = "_FORMANT.csv"
        self.transcript_pattern = "_TRANSCRIPT.csv"

        # Column definitions
        self.pose_cols = [
            "frame", "timestamp", "confidence", "success",
            "Tx", "Ty", "Tz", "Rx", "Ry", "Rz"
        ]

        self.gaze_cols = [
            "frame", "timestamp", "confidence", "success",
            "x_0", "y_0", "z_0", "x_1", "y_1", "z_1",
            "x_h0", "y_h0", "z_h0", "x_h1", "y_h1", "z_h1"
        ]

        self.features_cols = [
            "frame", "timestamp", "confidence", "success",
            *[f"x{i}" for i in range(68)],
            *[f"y{i}" for i in range(68)]
        ]

        self.au_cols = [
            "frame", "timestamp", "confidence", "success",
            "AU01_r", "AU02_r", "AU04_r", "AU05_r", "AU06_r",
            "AU09_r", "AU10_r", "AU12_r", "AU14_r", "AU15_r",
            "AU17_r", "AU20_r", "AU25_r", "AU26_r", "AU04_c",
            "AU12_c", "AU15_c", "AU23_c", "AU28_c", "AU45_c"
        ]

    def _load_df(self, file_path, columns):
        """Load a txt file with given columns and skip the first row."""
        return pd.read_csv(file_path, header=None, names=columns, skiprows=1)

    def detect_sessions(self):
        """Detect available sessions by looking for pose files."""
        session_ids = set()
        for root, dirs, files in os.walk(self.base_path):
            for f in files:
                if f.endswith(self.pose_pattern):
                    match = re.match(r"(\d+)_CLNF_pose\.txt", f)
                    if match:
                        session_ids.add(match.group(1))
        return sorted(session_ids)

    def merge_session_data(self, sid):
        """Merge data for a single session with ID = sid."""
        # Construct file paths
        pose_file = os.path.join(self.base_path, f"{sid}{self.pose_pattern}")
        gaze_file = os.path.join(self.base_path, f"{sid}{self.gaze_pattern}")
        features_file = os.path.join(self.base_path, f"{sid}{self.features_pattern}")
        au_file = os.path.join(self.base_path, f"{sid}{self.au_pattern}")
        covarep_file = os.path.join(self.base_path, f"{sid}{self.covarep_pattern}")
        formant_file = os.path.join(self.base_path, f"{sid}{self.formant_pattern}")
        transcript_file = os.path.join(self.base_path, f"{sid}{self.transcript_pattern}")

        # Check existence of core files
        if not (os.path.exists(pose_file) and os.path.exists(gaze_file)
                and os.path.exists(features_file) and os.path.exists(au_file)):
            print(f"Warning: Missing one or more CLNF files for session {sid}. Skipping...")
            return None

        # Load mandatory CLNF files
        pose_df = self._load_df(pose_file, self.pose_cols)
        gaze_df = self._load_df(gaze_file, self.gaze_cols)
        features_df = self._load_df(features_file, self.features_cols)
        au_df = self._load_df(au_file, self.au_cols)

        # Merge them on timestamp
        data = pd.merge(pose_df, gaze_df, on='timestamp', suffixes=('_pose', '_gaze'))
        data = pd.merge(data, features_df, on='timestamp', suffixes=('', '_features'))
        data = pd.merge(data, au_df, on='timestamp', suffixes=('', '_au'))

        # Optional merges with covarep, formant, transcript (if they exist)
        if os.path.exists(covarep_file):
            covarep_df = pd.read_csv(covarep_file)
            if 'timestamp' in covarep_df.columns:
                data = pd.merge(data, covarep_df, on='timestamp', how='left', suffixes=('', '_covarep'))
            else:
                print(f"Warning: 'timestamp' not found in {covarep_file}, skipping merge.")

        if os.path.exists(formant_file):
            formant_df = pd.read_csv(formant_file)
            if 'timestamp' in formant_df.columns:
                data = pd.merge(data, formant_df, on='timestamp', how='left', suffixes=('', '_formant'))
            else:
                print(f"Warning: 'timestamp' not found in {formant_file}, skipping merge.")

        if os.path.exists(transcript_file):
            transcript_df = pd.read_csv(transcript_file)
            if 'timestamp' in transcript_df.columns:
                data = pd.merge(data, transcript_df, on='timestamp', how='left', suffixes=('', '_transcript'))
            else:
                print(f"Warning: 'timestamp' not found in {transcript_file}, skipping merge.")

        # Fill NaNs
        data = data.fillna(0)
        return data

    def run(self):
        """Run the full merging process over all detected sessions."""
        session_ids = self.detect_sessions()
        print(f"Detected sessions: {session_ids}")

        merged_data = {}
        for sid in session_ids:
            data = self.merge_session_data(sid)
            if data is not None:
                merged_data[sid] = data
                print(f"Session {sid}: Merged DataFrame shape = {data.shape}")

        print("All sessions processed. 'merged_data' now contains a merged DataFrame for each session.")
        return merged_data


if __name__ == "__main__":
    base_path = "Dataset"  
    merger = DataMerger(base_path=base_path)
    merged_data = merger.run()
    # Now 'merged_data' is a dict with {session_id: DataFrame} pairs ready for further processing.
