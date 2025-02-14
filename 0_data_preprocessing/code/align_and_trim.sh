#!/bin/bash

# Check if input file is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <input_fasta> [<output_directory>]"
    exit 1
fi

# Set default output directory as the current directory if not specified
INPUT_FASTA="$1"
OUTPUT_DIR="./"

# If an output directory is provided, use it
if [ "$#" -ge 2 ]; then
    OUTPUT_DIR="$2"
fi

# Ensure the output directory exists and has write permissions
mkdir -p "$OUTPUT_DIR"
chmod +w "$OUTPUT_DIR" || { echo "Error: Cannot write to output directory '$OUTPUT_DIR'"; exit 1; }

# Create filenames for aligned and trimmed sequences in the specified output directory
BASENAME=$(basename "$INPUT_FASTA" .fasta)
ALIGNED_FASTA="$OUTPUT_DIR/${BASENAME}_aligned.fasta"
TRIMMED_FASTA="$OUTPUT_DIR/${BASENAME}_trimmed.fasta"


echo "Aligning sequences with MAFFT..."
mafft --auto "$INPUT_FASTA" > "$ALIGNED_FASTA"

seqkit stats "$ALIGNED_FASTA"

echo "Trimming alignment with trimAl..."
trimal -automated1 -in "$ALIGNED_FASTA" -out "$TRIMMED_FASTA"

seqkit stats "$TRIMMED_FASTA"


echo "Alignment and trimming complete!"
echo "Aligned file: $ALIGNED_FASTA"
echo "Trimmed file: $TRIMMED_FASTA"




