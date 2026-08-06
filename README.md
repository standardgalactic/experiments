# Granite Experiments

Experimental shell programs using local Ollama models.

The initial experiments use two Granite 4.1 models:

```
granite4.1:3b
granite4.1:8b
```

The smaller model is primarily used for inexpensive generation and drafting.
The larger model is used for criticism, evaluation, and revision guidance.

The repository is deliberately constructed as a sequence of Git commits so
that its history records the growth of the experimental apparatus.

## Experiments

The repository includes model smoke tests, comparative prompting, essay
generation, review, and a multi-stage essay pipeline.

## Requirements

A working Ollama installation with both Granite models available locally.

Verify them with:

```bash
ollama show granite4.1:3b
ollama show granite4.1:8b
```

## Output

Generated material is written under `output/`.

Diagnostic logs are written under `logs/`.
