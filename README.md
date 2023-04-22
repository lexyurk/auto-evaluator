# `Auto-evaluator` :brain: :memo:

`Context`

[Question-Answering](https://python.langchain.com/en/latest/use_cases/question_answering.html) over documents is a popular use-case for LLMs. LangChain  makes it easy to assemble LLM components (e.g., models and retrievers) into chains that support question answering: input documents are split into chunks and stored in a retriever. Relevant chunks are retrieved given a user `question`. These chunks are then passed to an LLM for synthesis into an `answer`.

![image](https://user-images.githubusercontent.com/122662504/233764113-f0f55ffd-49cc-4b61-b371-1afb1c644a1f.png)
 
 `Challenge`
  
It is not always obvious to determine how to grade these QA systems and, as a result, how to determine the parameters (e.g., chunk size) or components (e.g., model or retriever choice) that yield the best performance. This app aims to address these limitations. Recent [work](https://arxiv.org/abs/2212.09251) from Anthropic has used model-written evaluation sets. OpenAI and others [have shown](https://github.com/openai/evals/blob/main/evals/registry/modelgraded/closedqa.yaml) that model-graded evaluation is an effective way to evaluate models. This app combines these ideas into a single workspace, auto-generating a QA test set and auto-grading the result of the specified QA chain.

`Usage`

Inputs:

* `Documents`: Input a set of documents that you want to ask questions about.
* `(Optional) Test set`: Input a test set of question-answer pairs as a csv.

You can see (and use) an example input document and test set ***here*** (TO ADD).

![image](https://user-images.githubusercontent.com/122662504/233793757-aa5772ff-39e2-4331-9c43-ed1321166c80.png)

`Building the document retrieval`:

* The app will build a [retriver](https://blog.langchain.dev/retrieval/) for the input documents. 
* Retriever is a Langchain abstraction that accepts a question and returns a set of relevant documents. 
* The retriver can be selected by the user in the drop-down list in the configurations (see red panel in image above).

`Test set generation`:

* The app will auto-generate a test set of question-answer pair on the doc(s). 
* To do this, it uses the Langchain `QAGenerationChain` with the default prompt [here](https://github.com/hwchase17/langchain/blob/master/langchain/chains/qa_generation/prompt.py). 

`Model-graded evaluation`: 

* We use two different evals: 

(1) The app will evaluate the `relevance of the retrieved documents` relative to the question.

(2) The app will evaluate the `similarity of the LLM generated answer` relative to ground truth answer.

* The prompts for both can be seen [here](https://github.com/dankolesnikov/evaluator-app/blob/main/api/text_utils.py)
* Users can select which grading prompt to use: 

(1) `GRADE_ANSWER_PROMPT_FAST` and `GRADE_DOCS_PROMPT_FAST` do not ask the model to explain itself, which is faster.

(2) The other prompts explicitly ask the LLM grader to explain itself, resulting in higher latency but better explainability. 

`Experimental results`:

* The app will produce a table summarizing the results.
* It shows the question and the ground truth (expected) answer.
* It shows the chain-generated answer.
* It shows the binary score (PASS / FAIL) for retrieval and the answer.
* It shows the latency for retrieval and LLM answer summarization per question. 
* ***here*** (TO ADD) It shows the model grader output, which will be descriptive if the used specifies a a descriptive grading prompt.

![image](https://user-images.githubusercontent.com/122662504/233794221-c1f3f663-4295-4432-8b7b-c6bd89c9c273.png)

## User inputs

The left panel of the app (shown in red in the above image) has several user-configurable parameters.

`Number of eval questions` - This is the number of question-answer pairs to auto-generate for the given inputs documents. As mentioned above, question-answer pair auto-generation will use Langchain's `QAGenerationChain` with prompt specified [here](https://github.com/hwchase17/langchain/blob/master/langchain/chains/qa_generation/prompt.py).

`Chunk size` - Number of characters per chunk when the input documents are split. This [can impact answer quality](https://lancemartin.notion.site/lancemartin/Q-A-assistant-limitations-f576bf55b61c44e0970330ac3883315e). Retrievers often use text embedding similarity to select chunks related to the question. If the chunks are too large, each chunk may contain more information unrelated to the question, which may degrade the summarized answer quality. If chunks are too small, important context may be left out of the retrieved chunks.

`Overlap` - The overlap in characters between chunks. 
 
`Embedding` - The method used to embed chunks.
 
`Retriever` - The method used to [retrieve chunks](https://blog.langchain.dev/retrieval/) that are relevant to the user question. The default vector database used for `similarity search` is [FAISS](https://github.com/dankolesnikov/evaluator-app/blob/235105642ff1d0ab15be87be7328df71b403268b/api/evaluator_app.py#L131), but support for others is a welcome addition. You can also try other methods, such as [SVM](https://twitter.com/karpathy/status/1647025230546886658) or [TF-IDF](https://en.wikipedia.org/wiki/Tf%E2%80%93idf).

`Number of chunks to retrieve` - Number of chunks retrieved. More chunks can improve performance by giving the LLM more context for answer summarization.

`Model` - LLM for summarization of retrieved chunks into the answer.

`Model-graded evaluation prompt` - The prompt choice for model-graded evaluation. As mentioned above, the prompts can be seen [here](https://github.com/dankolesnikov/evaluator-app/blob/main/api/text_utils.py). More prompts would be a welcome addition.

## Logging experiments 

A user can select the desired configuration and then choose `Re-Run Experiment`.

This will run the new chain on the existing test set.

The results from all experiments will be summarized in the table and chart.

![image](https://user-images.githubusercontent.com/122662504/233794169-0bf36f04-546d-465c-ab3c-17d24742572e.png)

## Contributing

Run the frontend from `nextjs` folder:
`yarn dev`

Run the backend from `api` folder:
`uvicorn evaluator_app:app`

Test the `api` locally:
```
curl -X POST -F "files=@Docs/0333_text.txt" -F "num_eval_questions=1" -F "chunk_chars=1000" -F "overlap=100" -F "split_method=RecursiveTextSplitter" -F "retriver_type=similarity-search" -F "embeddings=OpenAI" -F "model_version=gpt-3.5-turbo" -F "grade_prompt=Fast" -F "num_neighbors=3" http://localhost:8000/evaluator-stream
 ```

## Deployment

Doppler auth:

```
doppler login // scope to dir
doppler config // select evaluator-ui project, environment dev
```
