from langchain_google_genai import GoogleGenerativeAIEmbeddings
from langchain_pinecone import PineconeVectorStore
from pinecone import Pinecone
from langchain_core.documents import Document
from uuid import uuid4
from dotenv import load_dotenv
import os

load_dotenv()

# Gemini
embeddings = GoogleGenerativeAIEmbeddings(model="models/text-embedding-004", google_api_key=os.getenv("GEMINI_API_KEY"))

# Pinecone
pc = Pinecone(api_key=os.getenv("PINCONE_API_KEY"))
index = pc.Index(os.getenv("PINCONE_INDEX_NAME"))

# Vector Store
vector_store = PineconeVectorStore(index=index, embedding=embeddings)

chunk_size = 1


def creating_documents():
    documents = []
    with open('./assets/bible.txt', 'r') as file:
        lines = file.readlines()
        num_chunks = (len(lines) + chunk_size - 1) // chunk_size
        for i in range(num_chunks):
            chunk_lines = lines[i * chunk_size:(i + 1) * chunk_size]
            chunk_string = ''.join(chunk_lines)
            document = Document(page_content=chunk_string)
            documents.append(document)

    return documents


def upload_documents_to_vector_database():
    documents_list = creating_documents()
    uuids = [str(uuid4()) for _ in range(len(documents_list))]
    vector_store.add_documents(documents=documents_list, ids=uuids)


if __name__ == '__main__':
    print("Start")
    # upload_documents_to_vector_database()
    print("Done")
