# VectorChord Suite for Railway

One-click PostgreSQL with VectorChord for scalable vector search + BM25 full-text search.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/H97WTl?referralCode=IcOuaJ&utm_medium=integration&utm_source=template&utm_campaign=generic)

## What's Included

| Extension | Purpose |
|-----------|---------|
| `vchord` | IVF+RaBitQ vector indexes - 100x faster indexing than HNSW at scale |
| `pg_tokenizer` | Text tokenization for BM25 search |
| `vchord_bm25` | BM25 full-text search with hybrid ranking |
| `vector` | pgvector compatibility layer |

## Why VectorChord?

- **Scales to billions of vectors** - IVF+RaBitQ quantization uses disk, not RAM
- **100x faster index builds** - Minutes instead of hours for 1M+ vectors
- **Same query syntax** - Drop-in replacement for pgvector (`<#>`, `<=>`, `<->`)
- **Hybrid search ready** - Combine vector similarity with BM25 text search

## Quick Start

1. **Deploy** via the button above or [this link](https://railway.com/deploy/H97WTl?referralCode=IcOuaJ&utm_medium=integration&utm_source=template&utm_campaign=generic)

2. **Create a vector index:**
   ```sql
   CREATE INDEX ON items USING vchordrq (embedding vector_ip_ops)
   WITH (options = $$
   residual_quantization = true
   [build.internal]
   lists = [1000]
   $$);
   ```

3. **Configure recall/latency tradeoff:**
   ```sql
   -- Set probes to 3-10% of lists for good recall
   ALTER DATABASE railway SET vchordrq.probes = 50;
   ```

4. **Query (same as pgvector):**
   ```sql
   SELECT * FROM items
   ORDER BY embedding <#> '[0.1, 0.2, ...]'::vector
   LIMIT 10;
   ```

## BM25 Full-Text Search

```sql
-- Create tokenizer
SELECT create_text_analyzer('my_analyzer', $$
pre_tokenizer = "unicode_segmentation"
$$);

-- Add BM25 column and index
ALTER TABLE docs ADD COLUMN tokens bm25vector;
CREATE INDEX ON docs USING bm25 (tokens bm25_ops);

-- Tokenize and search
UPDATE docs SET tokens = tokenize(content, 'my_analyzer');
SELECT * FROM docs WHERE tokens @@ to_bm25query('search terms');
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_USER` | `postgres` | Database user |
| `POSTGRES_PASSWORD` | (generated) | Database password |
| `POSTGRES_DB` | `postgres` | Default database name |
| `DATABASE_URL` | (generated) | Full connection string |

## Tuning Guide

| Vector Count | `lists` | `probes` | Notes |
|--------------|---------|----------|-------|
| 10K | 100 | 10 | Small dataset |
| 100K | 1000 | 50 | Medium dataset |
| 1M | 4000 | 100-200 | Large dataset |
| 10M+ | 10000+ | 500+ | Enterprise scale |

Formula: `lists = min(4 * sqrt(n), n / 40)`

## Links

- [VectorChord Documentation](https://docs.vectorchord.ai/)
- [VectorChord GitHub](https://github.com/tensorchord/VectorChord)
- [pg_tokenizer GitHub](https://github.com/tensorchord/pg_tokenizer.rs)
- [Docker Hub Image](https://hub.docker.com/r/tensorchord/vchord-suite)

## License

MIT
