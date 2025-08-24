# Global Truck & Food Review Analytics with Snowflake Iceberg & Cortex AI

## Project Overview
This project demonstrates a complete end-to-end workflow for ingesting, processing, and analyzing global truck and food reviews using Snowflake. It includes:

- External volume ingestion from AWS S3
- Iceberg table creation for metadata tracking
- Multilingual sentiment analysis with Snowflake Cortex AI
- Aggregation of sentiment by city and truck brand

## Tech Stack
- Snowflake (External Volumes, Iceberg Tables, Cortex AI)
- AWS S3
- SQL
- Optional: Python / Jupyter for visualization

## Workflow
1. **Create Storage Integration & Stage**
   - Connect Snowflake to AWS S3 bucket `vholreviews`
   - Configure IAM role & external ID

2. **External Volume**
   - Define external volume pointing to S3 bucket
   - Allow writes for ingestion of review CSVs

3. **Iceberg Table**
   - Create Iceberg table `iceberg_truck_reviews` to track metadata

4. **Insert Metadata**
   - Load staged CSV files into Iceberg table
   - Handle non-English reviews with Cortex AI translation

5. **Analytics & Views**
   - Create `product_unified_reviews` view with translated sentiment
   - Aggregate sentiment by `primary_city` and `truck_brand` in `product_sentiment` view

## Key Learnings / Challenges
- Configuring AWS IAM roles for Snowflake storage integration
- Troubleshooting `Error assuming AWS_ROLE` due to missing trust relationship
- Handling multilingual sentiment analysis with Cortex AI
- Working with Iceberg external tables for efficient metadata tracking

## Sample Output
| PRIMARY_CITY | TRUCK_BRAND           | AVG_REVIEW_SENTIMENT |
|--------------|---------------------|-------------------|
| Mumbai       | Cheeky Greek         | -0.0434           |
| Sao Paulo    | Kitakata Ramen Bar   | -0.0429           |
| Stockholm    | Freezing Point       | -0.0467           |
| Madrid       | Peking Truck         | -0.0418           |

## Files
- `sql/final_project.sql`: Complete Snowflake SQL workflow
- `data/product_sentiment_sample.csv`: Sample output of aggregated sentiment
- `data/product_unified_reviews_sample.csv`: Sample unified reviews data

## Next Steps
- Build interactive visualizations using Python (Plotly, Streamlit) or Tableau
- Extend sentiment analysis with additional NLP metrics
