import os
import logging
import requests
import torch
import torch.nn.functional as F
import numpy as np
from torch_geometric.data import Data
from torch_geometric.nn import GATConv, global_mean_pool

# Configure logging
logging.basicConfig(level=logging.INFO, format='[%(asctime)s] %(levelname)s:%(message)s')

# =============================================================================
# Model Definition
# =============================================================================
class CombinedSymptomMetricGNN(torch.nn.Module):
    def __init__(self, in_channels, hidden_channels, out_channels, heads=4, dropout=0.1, Tm=5.0, Td=5.0):
        super(CombinedSymptomMetricGNN, self).__init__()

        self.gat1 = GATConv(in_channels, hidden_channels, heads=heads, dropout=dropout)
        self.gat2 = GATConv(hidden_channels * heads, hidden_channels, heads=1, dropout=dropout)

        self.fc_ymrs = torch.nn.Linear(hidden_channels, 1)
        self.fc_phq9 = torch.nn.Linear(hidden_channels, 1)

        self.wm = torch.nn.Parameter(torch.tensor(1.0))  # Weight for YMRS
        self.wd = torch.nn.Parameter(torch.tensor(1.0))  # Weight for PHQ-9

        self.Tm = Tm
        self.Td = Td

        self.fc_out = torch.nn.Linear(hidden_channels, out_channels)
        self.softmax = torch.nn.Softmax(dim=-1)
        self.global_mean_pool = global_mean_pool

    def forward(self, x, edge_index, batch):
        x = F.elu(self.gat1(x, edge_index))
        x = F.elu(self.gat2(x, edge_index))
        x = self.global_mean_pool(x, batch)

        ymrs_scores = self.fc_ymrs(x).squeeze(1)
        phq9_scores = self.fc_phq9(x).squeeze(1)
        csm = self.wm * ymrs_scores - self.wd * phq9_scores

        logits = self.fc_out(x)
        logits = self.softmax(logits)
        return logits, ymrs_scores, phq9_scores, csm


# =============================================================================
# Data Preparation Classes
# =============================================================================
class DataMerger:
    def __init__(self, base_path):
        self.base_path = base_path

    def run(self):

        return {} 


class GraphConstructor:
    def __init__(self):
        self.nodes = []
        self.edges = []
        self.x = []
        self.node_index = 0
        self.index_mapping = {}

    def add_timestamp_nodes(self, timestamp, video_data, audio_data, question_text, answer_text):

        node_features = [0.1, 0.2, 0.3]  
        self.x.append(node_features)
        self.index_mapping[self.node_index] = timestamp
        self.node_index += 1

    def to_torch_geometric(self):
        x_tensor = torch.tensor(self.x, dtype=torch.float)
        edge_index_tensor = torch.empty((2, 0), dtype=torch.long)  
        data = Data(x=x_tensor, edge_index=edge_index_tensor)
        return data


# =============================================================================
# Fusion Logic
# =============================================================================
def fuse_predictions(gnn_logits, gnn_csm, gnn_ymrs_scores, gnn_phq9_scores,
                     wearable_url="https://wearable-device.onrender.com/predict/",
                     Tm=5.0, Td=5.0):

    # Extract GNN predictions
    gnn_probs = gnn_logits.cpu().numpy()[0]  # assuming single graph
    gnn_class = np.argmax(gnn_probs)
    gnn_csm_val = gnn_csm.cpu().numpy()[0]
    gnn_ymrs_val = gnn_ymrs_scores.cpu().numpy()[0]
    gnn_phq9_val = gnn_phq9_scores.cpu().numpy()[0]

    # Get wearable predictions
    try:
        response = requests.get(wearable_url, timeout=5)
        response.raise_for_status()
        wearable_data = response.json()
    except (requests.RequestException, ValueError) as e:
        logging.error(f"Failed to fetch wearable device predictions: {e}")
        # If wearable prediction fails, fallback to GNN prediction
        return {
            "final_class": int(gnn_class),
            "fused_probabilities": gnn_probs.tolist(),
            "gnn_probs": gnn_probs.tolist(),
            "wearable_probs": None,
            "gnn_ymrs": float(gnn_ymrs_val),
            "gnn_phq9": float(gnn_phq9_val),
            "wearable_ymrs": None,
            "wearable_phq9": None,
            "gnn_csm": float(gnn_csm_val),
            "fusion_reasoning": "Fell back to GNN prediction due to wearable prediction failure."
        }

    wearable_probs = wearable_data.get("probabilities", [0.33, 0.33, 0.33])
    wearable_class = wearable_data.get("prediction", 1)  
    wearable_ymrs_val = wearable_data.get("YMRS", None)
    wearable_phq9_val = wearable_data.get("PHQ9", None)

    # Rule-based fusion
    if gnn_class == wearable_class:
        final_class = gnn_class
        fusion_reason = "Both GNN and wearable device agree on the same class."
    else:
        # Average probabilities
        avg_probs = (gnn_probs + np.array(wearable_probs)) / 2.0
        final_class = np.argmax(avg_probs)

        if final_class == gnn_class or final_class == wearable_class:
            fusion_reason = ("Disagreement resolved by averaging probabilities. "
                             f"Chosen class {final_class} from averaged probabilities.")
        else:
            # Use CSM if still ambiguous
            if gnn_csm_val > Tm:
                final_class = 0  # Mania
                fusion_reason = ("Disagreement remains after averaging. "
                                 "CSM indicates mania.")
            elif gnn_csm_val < -Td:
                final_class = 2  # Depression
                fusion_reason = ("Disagreement remains after averaging. "
                                 "CSM indicates depression.")
            else:
                final_class = 1  # Euthymia
                fusion_reason = ("Disagreement remains after averaging. "
                                 "CSM indicates neither mania nor severe depression, choosing euthymia.")

    fused_probs = (gnn_probs + np.array(wearable_probs)) / 2.0

    result = {
        "final_class": int(final_class),
        "fused_probabilities": fused_probs.tolist(),
        "gnn_probs": gnn_probs.tolist(),
        "wearable_probs": wearable_probs,
        "gnn_ymrs": float(gnn_ymrs_val),
        "gnn_phq9": float(gnn_phq9_val),
        "wearable_ymrs": float(wearable_ymrs_val) if wearable_ymrs_val is not None else None,
        "wearable_phq9": float(wearable_phq9_val) if wearable_phq9_val is not None else None,
        "gnn_csm": float(gnn_csm_val),
        "fusion_reasoning": fusion_reason
    }

    return result


# =============================================================================
# Main Execution
# =============================================================================
if __name__ == "__main__":
    logging.info("Starting the inference and fusion process.")

    # Paths and parameters (adjust as needed)
    base_path = "Dataset"
    model_path = "best_model.pth"
    wearable_url = "https://wearable-device.onrender.com/predict/"
    Tm = 5.0
    Td = 5.0

    # 1. Merge the data
    merger = DataMerger(base_path=base_path)
    merged_data = merger.run()  # Replace with actual merging logic

    # 2. Construct the graph from data
    graph_constructor = GraphConstructor()

    # Example logic; you'd iterate over merged_data and add nodes
    # Here we just add one set of dummy nodes for demonstration
    graph_constructor.add_timestamp_nodes(timestamp=0, video_data={}, audio_data={},
                                          question_text="?", answer_text="!")
    data = graph_constructor.to_torch_geometric()

    if data.num_nodes == 0:
        logging.warning("No data nodes were constructed. Check your data preparation logic.")
    else:
        logging.info(f"Constructed graph with {data.num_nodes} nodes.")

    # 3. Load the model
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    data = data.to(device)

    # Assuming known dims from training
    input_dim = data.x.size(1) if data.num_nodes > 0 else 3
    hidden_dim = 64
    output_dim = 3

    model = CombinedSymptomMetricGNN(
        in_channels=input_dim,
        hidden_channels=hidden_dim,
        out_channels=output_dim,
        heads=4,
        dropout=0.1,
        Tm=Tm,
        Td=Td
    ).to(device)

    if os.path.exists(model_path):
        model.load_state_dict(torch.load(model_path, map_location=device))
        logging.info("Model weights loaded successfully.")
    else:
        logging.error(f"Model weight file not found at {model_path}. Using untrained model weights.")

    model.eval()

    batch = torch.zeros(data.num_nodes, dtype=torch.long, device=device)
    with torch.no_grad():
        logits, ymrs_scores, phq9_scores, csm = model(data.x, data.edge_index, batch)

    # Fusion
    fused_result = fuse_predictions(
        gnn_logits=logits,
        gnn_csm=csm,
        gnn_ymrs_scores=ymrs_scores,
        gnn_phq9_scores=phq9_scores,
        wearable_url=wearable_url,
        Tm=Tm,
        Td=Td
    )

    logging.info("Fusion completed. Final fused result:")
    logging.info(f"{fused_result}")
