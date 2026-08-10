"""
This script combines the auto-accepted fuzzy matches and the completed manual_review.csv and appends the ic2025size column from the Carnegie dataset to the flat file. 

Outputs: capstone_data_ic.csv - the original flat file + ic2025size column, with fuzzy matches and manual review applied. This file will be analysis ready once is_n5 and is_large_public columns are added.
Rows with no carnegie instnm match will have a null value for ic2025size.

Run in terminal:
python apply_manual_review.py --flat data/interim/capstone_data.csv --review manual_review.csv --carnegie data/external/carnegie_classification.csv
"""

import argparse
import pandas as pd
from rapidfuzz import process, fuzz
 
 
AUTO_ACCEPT = 90
 
 
def main(flat_path: str, review_path: str, carnegie_path: str) -> None:
 
    flat     = pd.read_csv(flat_path,     low_memory=False)
    review   = pd.read_csv(review_path,   low_memory=False)
    carnegie = pd.read_csv(carnegie_path, low_memory=False)
 
    flat.columns     = flat.columns.str.strip()
    review.columns   = review.columns.str.strip()
    carnegie.columns = carnegie.columns.str.strip()
 
    # Build instnm → ic2025size lookup
    carnegie_clean = carnegie.drop_duplicates(subset="instnm")
    size_lookup    = dict(zip(carnegie_clean["instnm"], carnegie_clean["ic2025size"]))
    instnm_list    = list(size_lookup.keys())
 
    # -- Auto-accepted matches (re-run matching for names not in review file) --
    review_names = set(review["college_name"].tolist())
    unique_names = flat["college_name"].dropna().unique().tolist()
    auto_names   = [n for n in unique_names if n not in review_names]
 
    print(f"Re-matching {len(auto_names):,} auto-accepted college names...")
 
    auto_map = {}
    for name in auto_names:
        result    = process.extractOne(name, instnm_list, scorer=fuzz.token_set_ratio)
        top_match = result[0]
        top_score = result[1]
        if top_score >= AUTO_ACCEPT:
            auto_map[name] = size_lookup.get(top_match)
 
    # -- Manual review matches --
    manual_map   = {}
    unrecognised = []
 
    for _, row in review.iterrows():
        college   = row["college_name"]
        your_match = str(row.get("your_match", "")).strip()
 
        if your_match and your_match.lower() != "nan":
            size_val = size_lookup.get(your_match)
            if size_val is None:
                unrecognised.append((college, your_match))
            manual_map[college] = size_val
        else:
            manual_map[college] = None   # explicit no-match → null
 
    if unrecognised:
        print("\n⚠️  These your_match values were not found in Carnegie — ic2025size will be null:")
        for college, instnm in unrecognised:
            print(f"   {college!r} → {instnm!r}")
        print()
 
    # -- Build full college_name → ic2025size map --
    combined_map = {**auto_map, **manual_map}
 
    # -- Append ic2025size to flat file --
    flat["ic2025size"] = flat["college_name"].map(combined_map)
 
    # -- Summary --
    populated = flat["ic2025size"].notna().sum()
    null_size = flat["ic2025size"].isna().sum()
    print(f"\nic2025size populated : {populated:,} rows")
    print(f"ic2025size null      : {null_size:,} rows")
 
    out_path = "capstone_data_ic.csv"
    flat.to_csv(out_path, index=False)
    print(f"\nWrote: {out_path}  ({len(flat):,} rows)")
    print("\nDone.")
 
 
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--flat",     required=True)
    parser.add_argument("--review",   required=True)
    parser.add_argument("--carnegie", required=True)
    args = parser.parse_args()
    main(args.flat, args.review, args.carnegie)