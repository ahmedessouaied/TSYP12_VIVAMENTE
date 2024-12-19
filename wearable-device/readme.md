# Wearable Device Integration

## Overview
The wearable device component of the Vivamente application is designed to seamlessly capture and process physiological features to aid in diagnosing mental health phases such as depression, remission, and mania. This system relies on an ensemble learning model that ensures high accuracy through robust training and validation techniques.

---

## Data Flow
1. **Data Upload**:
   - The wearable device captures physiological features such as:
     - **Heart Rate Variability (HRV)**
     - **Skin Conductivity**
   - The captured data is exported to **Azure Blob Storage** for further processing.

2. **Model Input**:
   - Physiological data is retrieved from Azure and prepared for model inference.

---

## Machine Learning Model
### Model Architecture
The wearable model is an ensemble learning system comprising:

1. **Base Models:**
   - **XGBoost**: Gradient boosting framework for structured data.
   - **CatBoost**: Optimized for categorical features and faster training.
   - **LightGBM**: Efficient gradient boosting framework with faster training and lower memory usage.

2. **Meta Model:**
   - **Ridge Regression**: Combines the predictions of the base models to generate the final output.

### Training Process
- **Hyperparameter Tuning:**
  - All base models are hypertuned using **Optuna** for optimal performance.
- **Cross-Validation:**
  - A 5-fold cross-validation strategy ensures robustness and prevents overfitting.

### Metrics
The model training and evaluation utilize the following clinical metrics:
- **Young Mania Rating Scale (YMRS):** Used for assessing mania severity.
- **Patient Health Questionnaire (PHQ-9):** Used for evaluating depression severity.

### Performance
- The model achieved an impressive **98% accuracy** on the evaluation dataset.
- This high performance is validated using 5-fold cross-validation, confirming that the model is robust and not overfitting.

### Output
The model outputs one of three classifications:
- **0:** Depression
- **1:** Remission
- **2:** Mania

---

## Integration with Vivamente
The predictions from the wearable model are combined with outputs from the **Graph Neural Network (GNN)** using a **Rule-Based Fusion Function**. This final output dynamically adjusts the prompt of the LLM to:

- Refine diagnostic accuracy.
- Provide tailored, phase-specific support to the user.
