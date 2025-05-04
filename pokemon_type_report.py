import pandas as pd

# Path to the Excel file
df_path = 'sql/pokemon.xlsx'
# Path to save the report
report_path = 'sql/pokemon_type_report.csv'

# Read the Excel file
df = pd.read_excel(df_path)

# Guess the type column name (e.g., 'Type 1', 'Type1', 'type1', etc.)
type_col = None
for col in df.columns:
    if 'type' in col.lower() and '1' in col:
        type_col = col
        break
if not type_col:
    raise ValueError('Type column not found. Please check the column names in the Excel file.')

# Count the number of Pokémon by type
type_counts = df[type_col].value_counts().reset_index()
type_counts.columns = ['Type', 'Count']

# Save the result as a CSV file
type_counts.to_csv(report_path, index=False)

print(f'Type count report saved to {report_path}')
