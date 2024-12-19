import os
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch_geometric.nn import GATConv, BatchNorm, global_mean_pool
from torch.optim import AdamW
from torch.optim.lr_scheduler import ReduceLROnPlateau
from torch_geometric.data import Data
import numpy as np
from sklearn.metrics import roc_auc_score, f1_score, recall_score, mean_absolute_error

from data_preprocessing import DataMerger
from graph_construction import GraphConstructor

######################################################
# CombinedSymptomMetricGNN Definition
######################################################
class CombinedSymptomMetricGNN(nn.Module):
    def __init__(self, in_channels, hidden_channels, out_channels, heads=4, dropout=0.1, Tm=5.0, Td=5.0):

        super(CombinedSymptomMetricGNN, self).__init__()
        
        # GAT layers
        self.gat1 = GATConv(in_channels, hidden_channels, heads=heads, dropout=dropout)
        self.gat2 = GATConv(hidden_channels * heads, hidden_channels, heads=1, dropout=dropout)

        # Fully connected layers for YMRS and PHQ-9 prediction
        self.fc_ymrs = nn.Linear(hidden_channels, 1)  # Predicting YMRS
        self.fc_phq9 = nn.Linear(hidden_channels, 1)  # Predicting PHQ-9

        # Weights for Combined Symptom Metric
        self.wm = nn.Parameter(torch.tensor(1.0))  # Weight for YMRS
        self.wd = nn.Parameter(torch.tensor(1.0))  # Weight for PHQ-9
        
        # Thresholds
        self.Tm = Tm
        self.Td = Td

        # Final classification layer
        self.fc_out = nn.Linear(hidden_channels, out_channels)
        self.softmax = nn.Softmax(dim=-1)

    def forward(self, x, edge_index, batch):
        # GAT layers
        x = F.elu(self.gat1(x, edge_index))
        x = F.elu(self.gat2(x, edge_index))

        # Global Mean Pooling
        x = global_mean_pool(x, batch)  # [num_graphs, hidden_channels]

        # Predict YMRS and PHQ-9
        ymrs_scores = self.fc_ymrs(x).squeeze(1)   # [num_graphs]
        phq9_scores = self.fc_phq9(x).squeeze(1)   # [num_graphs]

        # CSM = wm * YMRS - wd * PHQ9
        csm = self.wm * ymrs_scores - self.wd * phq9_scores

        # Classification logits
        logits = self.fc_out(x)  # [num_graphs, out_channels]
        logits = self.softmax(logits)
        return logits, ymrs_scores, phq9_scores, csm

######################################################
# Metrics Calculation
######################################################
def calculate_metrics(logits, true_labels, ymrs_scores, phq9_scores, csm):

    preds = torch.argmax(logits, dim=1).cpu().numpy()
    true = true_labels.cpu().numpy()

    # UAR (Macro Recall)
    uar = recall_score(true, preds, average='macro')

    # F1 Score (Macro)
    f1 = f1_score(true, preds, average='macro')

    # AUC-ROC (multi-class)
    try:
        auc = roc_auc_score(F.one_hot(torch.tensor(true), num_classes=logits.size(1)).numpy(),
                            logits.detach().cpu().numpy(),
                            multi_class='ovr')
    except ValueError:
        auc = 0.0

    mae_ymrs = mean_absolute_error(true, ymrs_scores.detach().cpu())
    mae_phq9 = mean_absolute_error(true, phq9_scores.detach().cpu())

    metrics = {
        "UAR": uar,
        "F1": f1,
        "AUC-ROC": auc,
        "MAE_YMRS": mae_ymrs,
        "MAE_PHQ9": mae_phq9
    }
    return metrics

######################################################
# Training and Evaluation Functions
######################################################
def train(model, data, optimizer):
    model.train()
    optimizer.zero_grad()
    # Forward pass
    logits, ymrs_scores, phq9_scores, csm = model(data.x, data.edge_index, torch.zeros(data.x.size(0), dtype=torch.long, device=data.x.device))
    loss = F.cross_entropy(logits[data.train_mask], data.y[data.train_mask])
    loss.backward()
    optimizer.step()
    return loss.item()

@torch.no_grad()
def evaluate(model, data):
    model.eval()
    logits, ymrs_scores, phq9_scores, csm = model(data.x, data.edge_index, torch.zeros(data.x.size(0), dtype=torch.long, device=data.x.device))
    pred = logits.argmax(dim=1)

    # Compute accuracy for train, val, test
    accs = []
    for mask_name in ['train_mask', 'val_mask', 'test_mask']:
        mask = getattr(data, mask_name)
        if mask.sum().item() == 0:
            accs.append(0.0)
            continue
        correct = pred[mask].eq(data.y[mask]).sum().item()
        total = mask.sum().item()
        acc = correct / total
        accs.append(acc)

    # Compute metrics (full dataset, for demonstration)
    metrics = calculate_metrics(logits, data.y, ymrs_scores, phq9_scores, csm)
    return accs, metrics

######################################################
# Main Script
######################################################
if __name__ == "__main__":
    # Merge Data
    base_path = "Dataset"  # Your dataset path
    merger = DataMerger(base_path=base_path)
    merged_data = merger.run()  # {session_id: DataFrame}

    # Construct Graph
    graph_constructor = GraphConstructor()
    # Example logic (adjust based on actual data)
    for sid, df in merged_data.items():
        if 'timestamp' in df.columns:
            df = df.sort_values(by='timestamp').reset_index(drop=True)
        else:
            df = df.reset_index(drop=True)

        
        video_columns = [c for c in df.columns if "Tx" in c or "Rx" in c or "Ty" in c or "Tz" in c or "Ry" in c or "Rz" in c]
        audio_columns = [c for c in df.columns if "covarep" in c.lower() or "formant" in c.lower()]

        for i, row in df.iterrows():
            timestamp = row['timestamp'] if 'timestamp' in df.columns else i
            video_data = row[video_columns].to_dict() if video_columns else {}
            audio_data = row[audio_columns].to_dict() if audio_columns else {}
            question_text = "Question placeholder"
            answer_text = "Answer placeholder"

            graph_constructor.add_timestamp_nodes(
                timestamp=timestamp,
                video_data=video_data,
                audio_data=audio_data,
                question_text=question_text,
                answer_text=answer_text
            )

    data = graph_constructor.to_torch_geometric()
    print("Constructed PyG Data:", data)

    # Create dummy labels and masks
    num_nodes = data.x.size(0)
    num_classes = 3
    data.y = torch.randint(0, num_classes, (num_nodes,))  # Dummy classification labels

    indices = torch.randperm(num_nodes)
    train_size = int(0.6 * num_nodes)
    val_size = int(0.2 * num_nodes)

    data.train_mask = torch.zeros(num_nodes, dtype=torch.bool)
    data.train_mask[indices[:train_size]] = True

    data.val_mask = torch.zeros(num_nodes, dtype=torch.bool)
    data.val_mask[indices[train_size:train_size+val_size]] = True

    data.test_mask = torch.zeros(num_nodes, dtype=torch.bool)
    data.test_mask[indices[train_size+val_size:]] = True

    # Setup training
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    data = data.to(device)

    model = CombinedSymptomMetricGNN(
        in_channels=data.x.size(1),
        hidden_channels=64,
        out_channels=num_classes,
        heads=4,
        dropout=0.1,
        Tm=5.0,
        Td=5.0
    ).to(device)

    optimizer = AdamW(model.parameters(), lr=0.001, weight_decay=1e-4)
    scheduler = ReduceLROnPlateau(optimizer, mode='max', factor=0.5, patience=10, verbose=True)

    epochs = 100
    patience = 10
    best_val_acc = 0.0
    best_weights = None
    patience_counter = 0

    for epoch in range(1, epochs + 1):
        loss = train(model, data, optimizer)
        (train_acc, val_acc, test_acc), metrics = evaluate(model, data)
        scheduler.step(val_acc)

        print(f"Epoch {epoch:03d}, Loss: {loss:.4f}, Train Acc: {train_acc:.4f}, "
              f"Val Acc: {val_acc:.4f}, Test Acc: {test_acc:.4f}, "
              f"UAR: {metrics['UAR']:.4f}, F1: {metrics['F1']:.4f}, AUC-ROC: {metrics['AUC-ROC']:.4f}, "
              f"MAE_YMRS: {metrics['MAE_YMRS']:.4f}, MAE_PHQ9: {metrics['MAE_PHQ9']:.4f}")

        if val_acc > best_val_acc:
            best_val_acc = val_acc
            best_weights = model.state_dict()
            patience_counter = 0
        else:
            patience_counter += 1
            if patience_counter >= patience:
                print("Early stopping triggered.")
                break

    if best_weights is not None:
        model.load_state_dict(best_weights)

    (train_acc, val_acc, test_acc), metrics = evaluate(model, data)
    print(f"Best Val Acc: {best_val_acc:.4f}, Final Test Acc: {test_acc:.4f}, "
          f"Final UAR: {metrics['UAR']:.4f}, F1: {metrics['F1']:.4f}, AUC-ROC: {metrics['AUC-ROC']:.4f}, "
          f"MAE_YMRS: {metrics['MAE_YMRS']:.4f}, MAE_PHQ9: {metrics['MAE_PHQ9']:.4f}")
    




