from langchain_community.document_loaders import PyPDFLoader, DirectoryLoader
from langchain_ollama import OllamaLLM
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_chroma import Chroma
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain.chains import create_history_aware_retriever, create_retrieval_chain
from langchain_core.runnables.history import RunnableWithMessageHistory
from langchain_community.chat_message_histories import ChatMessageHistory
from langchain_core.chat_history import BaseChatMessageHistory

class EMBSBot:
    def __init__(self):
        # Initialize the LLaMA model
        self.llm = OllamaLLM(model="hf.co/Hamatoysin/EMBS-G")

        # set up embeddings
        self.embeddings = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")

        # set up chroma db
        # self.populate_chroma() 

        # data retriever
        self.retriever = Chroma(
            persist_directory="RAG/chroma",
            embedding_function=self.embeddings
        ).as_retriever(
            search_type="similarity", 
            k=3
        )

        contextualize_sys_prompt = """Given a chat history and the latest user question \
        which might reference context in the chat history, formulate a standalone question \
        which can be understood without the chat history. Do NOT answer the question, \
        just reformulate it if needed and otherwise return it as is."""

        self.contextualized_q_prompt = ChatPromptTemplate.from_messages(
            [
                ("system", contextualize_sys_prompt),
                MessagesPlaceholder("chat_history"),
                ("human", "{input}"),
            ]
        )

        self.history_aware_retriever = create_history_aware_retriever(self.llm, self.retriever, self.contextualized_q_prompt)

        qa_sys_prompt = """You are a psycotheraoist professional. \
        Use the following pieces of retrieved context to answer the question. \
        It should consist of paragraph and conversational aspect rather than just a summary. \
        If you don't know the answer, just give him advice to reduce his case. \

        {context}"""

        self.qa_prompt = ChatPromptTemplate.from_messages(
            [
                ("system", qa_sys_prompt),
                MessagesPlaceholder("chat_history"),
                ("human", "{input}"),
            ]
        )

        self.qa_chain=create_stuff_documents_chain(self.llm, self.qa_prompt)
        self.rag_chain=create_retrieval_chain(self.history_aware_retriever, self.qa_chain)

        self.store = {} # stores chat history
        self.chatbot = self.get_chatbot()

    def populate_chroma(self):

        #Extract Data From the PDF File
        loader= DirectoryLoader('RAG/data',
                            glob="*.pdf",
                            loader_cls=PyPDFLoader)

        documents=loader.load()

        #Split the Data into Text Chunks
        text_splitter=RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
        text_chunks=text_splitter.split_documents(documents)

        Chroma.from_documents(text_chunks, embedding=self.embeddings, persist_directory='RAG/chroma')

    def get_session_history(self, session_id: str) -> BaseChatMessageHistory:
        if session_id not in self.store:
            self.store[session_id] = ChatMessageHistory()
        return self.store[session_id]

    def get_chatbot(self):
        chatbot = RunnableWithMessageHistory(
            self.rag_chain,
            self.get_session_history,
            input_messages_key="input",
            history_messages_key="chat_history",
            output_messages_key="answer",
        )
        return chatbot

    async def get_response(self, user_query: str):
        """Asynchronous method for processing user query through the chatbot."""

        response = self.chatbot.invoke(
            {"input": user_query},
            config={"configurable": {"session_id": "s1"}
            }, 
        )["answer"]

        return response