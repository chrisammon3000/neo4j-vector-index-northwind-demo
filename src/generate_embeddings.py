from pathlib import Path
from dotenv import load_dotenv, find_dotenv
load_dotenv(find_dotenv())
import polars as pl
from langchain.storage import LocalFileStore
from langchain.embeddings import CacheBackedEmbeddings
from langchain_openai import OpenAIEmbeddings

# Configure OpenAI embeddings
underlying_embeddings = OpenAIEmbeddings()

cache_dir = Path(__file__).parent / "_embeddings_cache"
cache_dir.mkdir(exist_ok=True)
store = LocalFileStore(cache_dir)

cached_embedder = CacheBackedEmbeddings.from_bytes_store(
    underlying_embeddings, store, namespace=underlying_embeddings.model
)

if __name__ == "__main__":
    # Load the data to embed
    neo4j_import_dir = Path(__file__).resolve().parent.parent / "neo4j" / "import"

    csv_paths = list(neo4j_import_dir.iterdir())
    csv_names = [ path.stem.replace("-", "_") for path in csv_paths if path.stem]
    csv_map = {name: path for name, path in zip(csv_names, csv_paths)}

    products_df = pl.read_csv(csv_map["products"])

    # Create embeddings for product names
    product_names = products_df["productName"].to_list()
    product_names_embeddings = cached_embedder.embed_documents(product_names)

    output_csv_path = neo4j_import_dir / "products-embeddings.csv"

    products_df = products_df.with_columns(
        pl.Series("productNameEmbedding", [ ",".join(map(str, embedding)) for embedding in product_names_embeddings])
    )

    products_df.write_csv(output_csv_path)
