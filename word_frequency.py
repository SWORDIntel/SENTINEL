#!/usr/bin/env python3
"""
Word frequency analyzer for SENTINEL repository
Lists the top 20 most frequent words across all files in a directory
"""

import os
import re
import argparse
from pathlib import Path
from collections import Counter
import string
from concurrent.futures import ProcessPoolExecutor, as_completed

# Define words to exclude (common stop words)
STOP_WORDS = {
    'the', 'and', 'a', 'to', 'of', 'in', 'is', 'that', 'it', 'for',
    'with', 'as', 'this', 'on', 'be', 'are', 'by', 'an', 'was', 'can',
    'from', 'or', 'you', 'have', 'not', 'will', 'at', 'your', 'all', 'has',
    'we', 'been', 'if', 'they', 'their', 'but', 'when', 'what', 'which',
    'so', 'there', 'no', 'would', 'our', 'about', 'who', 'its', 'only',
    'also', 'them', 'than', 'then', 'some', 'my', 'other', 'do', 'more',
    'using', 'used', 'these', 'such', 'use', 'any', 'up', 'may', 'should',
    'could', 'how', 'into', 'one', 'out', 'like', 'just', 'each', 'after',
    'through', 'before', 'between', 'those', 'over', 'under', 'very', 'were',
    'had', 'he', 'she', 'his', 'her', 'i', 'me', 'am', 'us', 'him', 'hers',
    'we', 'they', 'them', 'our', 'their', 'theirs', 'being', 'been', 'did',
    'does', 'most'
}

def read_file_content(file_path):
    """Read file content safely, handling encoding issues."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return f.read()
    except UnicodeDecodeError:
        try:
            with open(file_path, 'r', encoding='latin-1') as f:
                return f.read()
        except Exception as e:
            print(f"Error reading {file_path}: {e}")
            return ""

def clean_text(text):
    """Clean text by removing punctuation, special characters, and numbers."""
    # Replace URLs with a space
    text = re.sub(r'http[s]?://\S+', ' ', text)
    
    # Replace markdown links with a space
    text = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', text)
    
    # Replace backslashes with a space
    text = text.replace('\\', ' ')
    
    # Replace punctuation with a space
    for char in string.punctuation:
        text = text.replace(char, ' ')
    
    # Remove digits
    text = re.sub(r'\d+', ' ', text)
    
    # Convert to lowercase
    text = text.lower()
    
    # Replace multiple spaces with a single space
    text = re.sub(r'\s+', ' ', text)
    
    return text

def extract_words(file_path):
    """Extract meaningful words from a file."""
    content = read_file_content(file_path)
    if not content:
        return Counter()
    
    cleaned_text = clean_text(content)
    words = cleaned_text.split()
    
    # Filter out stop words and words that are too short
    meaningful_words = [word for word in words if word not in STOP_WORDS and len(word) > 2]
    
    return Counter(meaningful_words)

def process_files_batch(files):
    """Process a batch of files and return their word counts."""
    word_counter = Counter()
    for file_path in files:
        file_counter = extract_words(file_path)
        word_counter.update(file_counter)
    return word_counter

def main():
    """Main function to analyze word frequency."""
    parser = argparse.ArgumentParser(description='Analyze word frequency in files.')
    parser.add_argument('--dir', default='gitstar/readmes/UNSORTED', help='Directory to analyze')
    parser.add_argument('--top', type=int, default=20, help='Number of top words to display')
    parser.add_argument('--workers', type=int, default=os.cpu_count(), help='Number of worker processes')
    parser.add_argument('--exclude', type=str, default='progress.md', help='Comma-separated list of files to exclude')
    parser.add_argument('--min-length', type=int, default=3, help='Minimum word length to consider')
    parser.add_argument('--include-code', action='store_true', help='Include words from code blocks')
    
    args = parser.parse_args()
    
    # Get all markdown files from the directory
    target_dir = Path(args.dir)
    all_files = list(target_dir.glob('*.md'))
    
    # Exclude specified files
    exclude_files = set(args.exclude.split(','))
    files_to_process = [f for f in all_files if f.name not in exclude_files]
    
    print(f"Found {len(files_to_process)} files to analyze")
    
    # Create batches for parallel processing
    batch_size = max(1, len(files_to_process) // args.workers)
    batches = [files_to_process[i:i + batch_size] for i in range(0, len(files_to_process), batch_size)]
    
    # Process files in parallel
    word_counter = Counter()
    with ProcessPoolExecutor(max_workers=args.workers) as executor:
        futures = [executor.submit(process_files_batch, batch) for batch in batches]
        for future in as_completed(futures):
            try:
                batch_counter = future.result()
                word_counter.update(batch_counter)
            except Exception as e:
                print(f"Error processing batch: {e}")
    
    # Filter out words that are too short
    if args.min_length > 2:  # We already filter words <= 2 characters
        word_counter = Counter({word: count for word, count in word_counter.items() 
                               if len(word) >= args.min_length})
    
    # Get the top N words
    top_words = word_counter.most_common(args.top)
    
    # Display results
    print(f"\nTop {args.top} words in {args.dir}:")
    max_word_len = max(len(word) for word, _ in top_words)
    max_count_len = max(len(str(count)) for _, count in top_words)
    
    print("\n{:<{}} | {:<{}} | {}".format("Word", max_word_len, "Count", max_count_len, "Percentage"))
    print("-" * (max_word_len + max_count_len + 15))
    
    total_words = sum(word_counter.values())
    for word, count in top_words:
        percentage = (count / total_words) * 100
        print("{:<{}} | {:<{}} | {:.2f}%".format(word, max_word_len, count, max_count_len, percentage))
    
    print(f"\nTotal unique words: {len(word_counter)}")
    print(f"Total words analyzed: {total_words}")

if __name__ == "__main__":
    main() 