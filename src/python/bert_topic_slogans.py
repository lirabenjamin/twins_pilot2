#!/usr/bin/env python3
"""
Run BERTopic modeling on marketing slogans data.
Creates a visualization with one point per document showing topic clusters.
"""

import pandas as pd
import numpy as np
from bertopic import BERTopic
import matplotlib.pyplot as plt
from pathlib import Path

def load_data(data_path):
    """Load the analysis data and extract slogans."""
    df = pd.read_parquet(data_path)

    # Filter out missing slogans
    df_slogans = df[df['slogan'].notna()].copy()

    print(f"Loaded {len(df_slogans)} slogans from {len(df)} total rows")
    print(f"Learner party breakdown:")
    print(df_slogans['learner_party'].value_counts())

    return df_slogans

def run_bertopic(slogans, min_topic_size=3):
    """Run BERTopic on the slogans."""
    print(f"\nRunning BERTopic with min_topic_size={min_topic_size}...")

    # Initialize BERTopic model
    # Use smaller embeddings model for faster processing
    topic_model = BERTopic(
        min_topic_size=min_topic_size,
        verbose=True,
        calculate_probabilities=False  # Faster without probabilities
    )

    # Fit the model
    topics, probabilities = topic_model.fit_transform(slogans)

    print(f"\nIdentified {len(set(topics))} topics (including outliers)")
    print(f"Topic distribution:")
    unique, counts = np.unique(topics, return_counts=True)
    for topic_id, count in zip(unique, counts):
        topic_label = "Outliers" if topic_id == -1 else f"Topic {topic_id}"
        print(f"  {topic_label}: {count} slogans")

    return topic_model, topics

def create_visualization(topic_model, df_slogans, topics, output_path):
    """Create scatter plot visualization of documents in 2D topic space."""
    print("\nCreating visualization...")

    # Get document embeddings reduced to 2D
    reduced_embeddings = topic_model._reduce_dimensionality(topic_model.embedding_model.encode(df_slogans['slogan'].tolist()))

    # Create figure
    fig, ax = plt.subplots(figsize=(12, 8))

    # Color by learner party
    party_colors = {'D→R': '#0015BC', 'R→D': '#E81B23'}

    for party in df_slogans['learner_party'].unique():
        mask = df_slogans['learner_party'] == party
        party_docs = reduced_embeddings[mask]

        ax.scatter(
            party_docs[:, 0],
            party_docs[:, 1],
            c=party_colors.get(party, 'gray'),
            label=party,
            alpha=0.6,
            s=50,
            edgecolors='white',
            linewidth=0.5
        )

    ax.set_xlabel('UMAP Dimension 1', fontsize=12)
    ax.set_ylabel('UMAP Dimension 2', fontsize=12)
    ax.set_title('BERTopic Visualization of Marketing Slogans\n(One point per slogan)', fontsize=14)
    ax.legend(title='Learner Party', fontsize=10)
    ax.grid(True, alpha=0.3)

    # Save figure
    plt.tight_layout()
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    print(f"Saved visualization to {output_path}")

    return fig

def save_topic_info(topic_model, output_path):
    """Save topic information to a CSV file."""
    topic_info = topic_model.get_topic_info()
    topic_info.to_csv(output_path, index=False)
    print(f"Saved topic information to {output_path}")

def main():
    # Set paths
    data_path = Path("data/processed/analysis_data.parquet")
    output_dir = Path("output/figures")
    output_dir.mkdir(parents=True, exist_ok=True)

    # Load data
    df_slogans = load_data(data_path)

    # Run BERTopic
    topic_model, topics = run_bertopic(df_slogans['slogan'].tolist())

    # Add topics to dataframe
    df_slogans['topic'] = topics

    # Create visualization
    viz_path = output_dir / "bert_topic_slogans.png"
    create_visualization(topic_model, df_slogans, topics, viz_path)

    # Save topic information
    topic_info_path = output_dir / "bert_topic_info.csv"
    save_topic_info(topic_model, topic_info_path)

    # Print some example slogans from each topic
    print("\n" + "="*80)
    print("Example slogans from each topic:")
    print("="*80)
    for topic_id in sorted(df_slogans['topic'].unique()):
        if topic_id == -1:
            print(f"\nOutliers:")
        else:
            topic_words = topic_model.get_topic(topic_id)
            top_words = ", ".join([word for word, _ in topic_words[:5]])
            print(f"\nTopic {topic_id} (keywords: {top_words}):")

        examples = df_slogans[df_slogans['topic'] == topic_id]['slogan'].head(3)
        for i, slogan in enumerate(examples, 1):
            print(f"  {i}. \"{slogan}\"")

    print("\n" + "="*80)
    print("Analysis complete!")
    print("="*80)

if __name__ == "__main__":
    main()
