""" Fuzzy matching of college names to Carnegie Classification of Institutions of Higher Education for feature engineering. 
- Score >= 90 : auto-accept
- Score < 90 : manual review required

Output: manual_review.csv that holds college name, fuzzy match score, and your match (which we can fill in with the correct instnm value, or leave blank if there is no match)

Run in terminal: 
python fuzzy_match.py --flat data/interim/capstone_data.csv --carnegie data/external/carnegie_classification.csv"""


import argparse
import pandas as pd
from rapidfuzz import process, fuzz

AUTO_ACCEPT = 90

def main(flat_path: str, carnegie_path: str) -> None:
 
    flat     = pd.read_csv(flat_path,     low_memory=False)
    carnegie = pd.read_csv(carnegie_path, low_memory=False)
 
    flat.columns     = flat.columns.str.strip()
    carnegie.columns = carnegie.columns.str.strip()
 
    for col, df, fname in [
        ("college_name", flat,     flat_path),
        ("instnm",       carnegie, carnegie_path),
        ("ic2025size",   carnegie, carnegie_path),
    ]:
        if col not in df.columns:
            raise ValueError(f"'{col}' column not found in {fname}")
 
    instnm_list = carnegie.drop_duplicates(subset="instnm")["instnm"].tolist()
    unique_names = flat["college_name"].dropna().unique().tolist()
 
    print(f"Flat file rows          : {len(flat):,}")
    print(f"Carnegie institutions   : {len(instnm_list):,}")
    print(f"Unique college names    : {len(unique_names):,}\n")
 
    review_rows = []
 
    for name in unique_names:
        result     = process.extractOne(name, instnm_list, scorer=fuzz.token_set_ratio)
        top_match  = result[0]
        top_score  = round(result[1], 1)
 
        if top_score < AUTO_ACCEPT:
            review_rows.append({
                "college_name" : name,
                "top_score"    : top_score,
                "your_match"   : "",
            })
 
    auto_count   = len(unique_names) - len(review_rows)
    print(f"Auto-accepted (>= {AUTO_ACCEPT})  : {auto_count:,}")
    print(f"Needs review  (<  {AUTO_ACCEPT})  : {len(review_rows):,}\n")
 
    if review_rows:
        review_df = pd.DataFrame(review_rows).sort_values("top_score", ascending=False)
        review_df.to_csv("manual_review.csv", index=False)
        print("Wrote: manual_review.csv")
        print("Fill in 'your_match' with the correct instnm value, or leave blank for no match.")
    else:
        print("All college names auto-accepted — manual_review.csv not needed.")
 
    print("\nDone.")
 
 
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--flat",     required=True)
    parser.add_argument("--carnegie", required=True)
    args = parser.parse_args()
    main(args.flat, args.carnegie)