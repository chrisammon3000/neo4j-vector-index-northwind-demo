from pathlib import Path
from dotenv import load_dotenv, find_dotenv
load_dotenv(find_dotenv())
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
    Path("./examples").mkdir(exist_ok=True)
    while True:
        query = input("Enter query: ")

        embedded_query = cached_embedder.embed_documents([query])

        # write to text file named for query
        output_path = f'./examples/{query.lower().replace(" ", "_")}'
        with open(output_path, "w") as f:
            f.write(",".join(map(str, embedded_query[0])))

        # handle sigint
        try:
            pass
        except KeyboardInterrupt:
            break
