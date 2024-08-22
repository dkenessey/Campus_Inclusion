<h1 style="font-size:36px;"> <div align="center"> <b> Campus Inclusion Ratings </b> </div> </h1>

<h1 style="font-size:24px;"> <b> 1. Project Description & Business Problem </b> </h1>
The National Campus Inclusion Initiative (NCII) is a non-profit organization focused on promoting diversity and inclusion in higher education institutions across the United States. The NCII wants to identify the key factors that contribute to a higher inclusivity rating for campuses and understand the relationship between the size and type of community and the inclusivity rating. This analysis will help the NCII prioritize efforts and resources towards campuses that need the most improvement and identify best practices from high-rating campuses.

<h1 style="font-size:24px;"> <b> 2. Dataset </b> </h1>
The data (pride_index.csv) containing campus inclusivity ratings is shared via an .csv file. The dataset contains 245 rows and 6 columns (campus name, campus location, inclusion rating, student body size, community size, and community type). The original dataset was provided by Data In Motion through their weekly Data Analyst Challenge. This dataset was cleaned in MySQL, resulting in a new .csv file (pride_index_cleaned.csv) that contains 239 rows and 8 columns (campus name, city, state, inclusion rating, student body size, student body size type, community size, and community type).

<h1 style="font-size:24px;"> <b> 3. Software used </b> </h1>

- MySQL == 9.0.1
- Python == 3.10.12
  - numpy == 1.25.2
  - pandas == 2.0.3
  - matplotlib == 3.7.1
  - seaborn == 0.13.1
  - geopandas == 0.13.2
  - scipy == 1.11.4
  - sckit-posthocs == 0.9.0

<h1 style="font-size:24px;"> <b> 4. Key Findings </b> </h1>

- The country-wide average inclusion rating was 3.97. States with the highest average inclusion rating included Vermont, Indiana, and Nebraska. <br>
- Larger campuses tend to receive higher inclusion ratings, though this relationship is only moderate, indicating that other factors also impact the ratings received. <br>
- Campuses located in more urban settings generally have higher inclusivity ratings. <br>
- Overall, campuses located in medium-sized communities with small or medium-sized student populations in the Northeast and Midwest regions received the highest inclusivity ratings. <br> 

<h1 style="font-size:24px;"> <b> 4. Recommendations </b> </h1>

- <b>Support Small & Rural Campuses:</b> Prioritize resources for campuses with small student populations and those in rural areas, which often have lower inclusivity ratings. <br>

- <b>Adopt Best Practices:</b> Identify and document effective inclusivity strategies from high-rated campuses. Develop and share guidelines based on these practices to assist other campuses in enhancing their inclusivity. <br>

- <b>Expand Data Collection Efforts:</b> Broaden data collection effortd to include campuses in currently unrepresented states (e.g., Alaska, Delaware, etc.). This will provide a more comprehensive view of inclusivity across regions and help identify new patterns or outliers. <br>

- <b>Foster Collaboration:</b> Promote partnerships between high-inclusivity urban campuses and those in smaller or rural areas through academic, sports, and social engagements. These collaborations can facilitate knowledge and resource sharing to improve inclusivity across various community types. <br>

- <b>Reward Excellence:</b> Create awards or recognition programs for campuses with exemplary inclusivity practices. Public acknowledgment can inspire campuses to improve their inclusivity efforts and share successful strategies, fostering overall improvement across the board. <br>


<h1 style="font-size:24px;"> <b> 5. Skills Demonstrated </b> </h1>

- MySQL: Data Cleaning <br>
  - Data Definition Language: ALTER, DROP
  - Data Query Language: <br>
    - Basic Query Operations: SELECT
    - Filtering & Conditions: WHERE, CASE, HAVING
    - Sorting & Ordering: ORDER BY
    - Grouping: GROUP BY
    - Aggregation: MIN, MAX, AVG, COUNT, ROUND
    - String functions: LOWER, UPPER, SUBSTRING_INDEX, TRIM
    - Joins & Relationships: INNER JOIN, 
  - Data Manipulation Language: UPDATE, DELETE, CAST <br>
- Python: Exploratory Data Analysis & Hypothesis Testing
  - basic python: functional programming
  - pandas: shape, nununique, iloc, isnull, describe, mode, map, merge, groupby, nlargest, nsmallest, unique, value_counts
  - matplotlib & seaborn: histogram, boxplot, heatmap
  - geopandas: choropleth
  - scipy: kruskal, spearmanr
  - scikit_posthocs: dunn
  
    
    
