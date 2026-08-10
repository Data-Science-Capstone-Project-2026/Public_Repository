import pandas as pd

output_path = "../../data/processed/capstone_data_processed.csv"

df = pd.read_csv("../../data/interim/capstone_data_ic.csv")

LOCAL_STATES = {"OR", "WA", "CA"}
#LOCAL_STATES = {"OR", "WA"}

nw5 = {"REED COLLEGE",
       "LEWIS AND CLARK COLLEGE",
       "WHITMAN COLLEGE",
       "UNIVERSITY OF PUGET SOUND"}


three_large_public = {"OREGON STATE UNIVERSITY",
                      "UNIVERSITY OF OREGON",
                      "PORTLAND STATE UNIVERSITY"}



df["is_nw5"] = df["college_name"].isin(nw5).astype(int)

df["is_three_large_public"] = df["college_name"].isin(three_large_public).astype(int)

df["is_local_large_public"] = (
    df["college_state"].isin(LOCAL_STATES) &
    (df["private"] == 0) &
    df["ic2025size"].isin([4, 5]) &
    ~df["college_name"].isin(three_large_public)
).astype(int)

df["is_local_private"] = (
    df["college_state"].isin(LOCAL_STATES) &
    (df["private"] == 1) &
    ~df["college_name"].isin(nw5)
).astype(int)
 
df["dest_other"] = (
    (df["is_nw5"] == 0) &
    (df["is_three_large_public"] == 0) &
    (df["is_local_large_public"] == 0) &
    (df["is_local_private"] == 0)
).astype(int)

#df = df[df["dest_other"] != 1]

df.to_csv(output_path, index=False)