import torch
from torch_geometric.data import Data
import torch_geometric.utils as tg_utils
import pandas as pd
import networkx as nx
from data_preprocessing import DataMerger  # from previous code
# Ensure that "DataMerger" merges transcripts properly and that transcripts have 'speaker' and 'value' columns.

class GraphConstructor:
    def __init__(self):
        self.graph = nx.DiGraph()  # Directed graph for relationships
        self.summary_node = "summary_node"
        self.graph.add_node(self.summary_node, type="summary")
        self.edges = []  # Store edges for PyG conversion
        self.node_features = {}  # Store features
        self.node_types = {}  # Track node types
        self.node_counter = 0  # Global counter for nodes
        self.node_mapping = {}  # Map node names to IDs
        self._add_node(self.summary_node, "summary")  # Ensure summary_node is added

    def _add_node(self, name, node_type, data=None):
        if name not in self.node_mapping:
            node_id = self.node_counter
            self.node_mapping[name] = node_id
            self.node_counter += 1
            self.node_types[node_id] = node_type
            self.node_features[node_id] = data if data else []

    def _add_edge(self, source, target):
        if source in self.node_mapping and target in self.node_mapping:
            self.edges.append((self.node_mapping[source], self.node_mapping[target]))
        else:
            print(f"Warning: Attempted to add edge from {source} to {target}, but one of the nodes is missing.")

    def add_timestamp_nodes(self, timestamp, video_data, audio_data, question_text, answer_text):
        proxy_node = f"proxy_{timestamp}"
        self._add_node(proxy_node, "proxy")

        # Add video node
        video_node = f"video_{timestamp}"
        self._add_node(video_node, "video", video_data)
        self._add_edge(video_node, proxy_node)

        # Add audio node
        audio_node = f"audio_{timestamp}"
        self._add_node(audio_node, "audio", audio_data)
        self._add_edge(audio_node, proxy_node)

        # Add question node
        question_node = f"question_{timestamp}"
        self._add_node(question_node, "question", question_text)
        self._add_edge(question_node, proxy_node)

        # Add answer node
        answer_node = f"answer_{timestamp}"
        self._add_node(answer_node, "answer", answer_text)
        self._add_edge(proxy_node, answer_node)
        self._add_edge(answer_node, self.summary_node)

    def to_torch_geometric(self):
        if len(self.edges) == 0:
            edge_index = torch.empty((2, 0), dtype=torch.long)
        else:
            edge_index = torch.tensor(self.edges, dtype=torch.long).t().contiguous()

        # Determine the maximum feature size
        max_feature_size = 1
        for features in self.node_features.values():
            if isinstance(features, dict):
                size = len(features.values())
            elif isinstance(features, (list, tuple)):
                size = len(features)
            elif isinstance(features, str):
                size = 1
            else:
                size = 1
            if size > max_feature_size:
                max_feature_size = size

        x = torch.zeros((len(self.node_mapping), max_feature_size), dtype=torch.float)

        for node_id, features in self.node_features.items():
            if isinstance(features, dict):
                feature_values = [hash(str(v)) % 1000 for v in features.values()]
            elif isinstance(features, str):
                feature_values = [hash(features) % 1000]
            elif isinstance(features, (list, tuple)):
                numeric_vals = []
                for f in features:
                    if isinstance(f, (int, float)):
                        numeric_vals.append(f)
                    else:
                        numeric_vals.append(hash(str(f)) % 1000)
                feature_values = numeric_vals
            else:
                feature_values = [0]

            feature_tensor = torch.tensor(feature_values, dtype=torch.float)
            x[node_id, :len(feature_tensor)] = feature_tensor

        return Data(x=x, edge_index=edge_index)


if __name__ == "__main__":
    base_path = "Dataset"  
    merger = DataMerger(base_path=base_path)
    merged_data = merger.run()

    graph_constructor = GraphConstructor()


    for sid, df in merged_data.items():
        # Sort by timestamp if not already sorted, if a timestamp column exists
        if 'timestamp' in df.columns:
            df = df.sort_values(by='timestamp')
            df = df.reset_index(drop=True)
        


    
        # Filter transcript entries
        transcript_entries = df.dropna(subset=['speaker', 'value'])
        
        # For demonstration, pair consecutive lines: one from Ellie (question) and next from Participant (answer).
        # If the data doesn't always alternate, you'll need more complex logic.
        # We'll just iterate in steps of 2 for simplicity.
        
        # Extract video and audio data:
        # Suppose 'video_columns' and 'audio_columns' help identify which columns are from video/audio.
        video_columns = [c for c in df.columns if "Tx" in c or "Rx" in c or "Ty" in c or "Tz" in c or "Ry" in c or "Rz" in c]
        audio_columns = [c for c in df.columns if "covarep" in c.lower() or "formant" in c.lower()]

        if 'timestamp' in df.columns:
            time_col = 'timestamp'
        else:
            # fallback: use index as timestamp
            time_col = None

        for i in range(len(transcript_entries)):
            row = transcript_entries.iloc[i]
            speaker = row['speaker']
            utterance = row['value']

            timestamp = row[time_col] if time_col else i

            video_data = {}
            audio_data = {}

            if video_columns:
                video_data = row[video_columns].to_dict()
            if audio_columns:
                audio_data = row[audio_columns].to_dict()

            
            if speaker.lower() != "participant":
                question_text = utterance
                answer_text = "no_answer" 
                # Add node now. If next line is participant, we might need to re-add?
                # Instead, let's peek the next line:
                if i+1 < len(transcript_entries):
                    next_row = transcript_entries.iloc[i+1]
                    if next_row['speaker'].lower() == "participant":
                        answer_text = next_row['value']

        pairs = []
        i = 0
        rows = transcript_entries.reset_index(drop=True)
        while i < len(rows):
            if rows.iloc[i]['speaker'].lower() == "ellie":
                question_text = rows.iloc[i]['value']
                timestamp = rows.iloc[i][time_col] if time_col else i
                # Check next line for participant
                answer_text = "no_answer"
                if i+1 < len(rows) and rows.iloc[i+1]['speaker'].lower() == "participant":
                    answer_text = rows.iloc[i+1]['value']
                    i += 2
                else:
                    i += 1
                # Extract modality features at this timestamp or approximate
                # For simplicity, re-extract at the question line:
                video_data = {}
                audio_data = {}
                if video_columns:
                    video_data = rows.iloc[i-1][video_columns].to_dict()
                if audio_columns:
                    audio_data = rows.iloc[i-1][audio_columns].to_dict()

                graph_constructor.add_timestamp_nodes(
                    timestamp=timestamp,
                    video_data=video_data,
                    audio_data=audio_data,
                    question_text=question_text,
                    answer_text=answer_text
                )
            else:
                # If line is participant first (no ellie before?), skip or handle differently
                i += 1

    # Convert to PyTorch Geometric format
    data = graph_constructor.to_torch_geometric()
    print(data)
    print("Graph construction completed!")
