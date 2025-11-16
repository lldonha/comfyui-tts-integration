# Guia Completo: Integração n8n + ComfyUI TTS

Este guia mostra como criar um workflow completo no n8n para gerar áudio usando o ComfyUI IndexTTS-2.

## Arquitetura

```
n8n (Docker)
    ↓
Wrapper API (porta 8001)
    ↓
ComfyUI (porta 8000)
    ↓
Áudio gerado
```

## Workflow n8n - 3 Nós

### Nó 1: Execute TTS (HTTP Request)

**Nome:** `ComfyUI - Execute TTS`

**Configuração:**
- **Method:** POST
- **URL:** `http://host.docker.internal:8001/prompt`
- **Authentication:** None
- **Send Body:** Yes
- **Body Content Type:** JSON
- **Specify Body:** Using Fields Below

**Body Parameters:**

| Name | Value |
|------|-------|
| `prompt` | `{{ JSON.stringify($json.comfy_workflow) }}` |
| `client_id` | `{{ $json.client_id }}` |

**Entrada esperada** (exemplo de JSON que você deve passar para este nó):

```json
{
  "comfy_workflow": {
    "47": {
      "inputs": {
        "TTS_engine": ["123", 0],
        "opt_narrator": ["51", 0],
        "text": "The babysitter called to say the children were asleep upstairs.",
        "seed": 3962542152,
        "enable_chunking": true,
        "max_chars_per_chunk": 400,
        "chunk_combination_method": "auto",
        "silence_between_chunks_ms": 100,
        "enable_audio_cache": true,
        "batch_size": 0
      },
      "class_type": "UnifiedTTSTextNode",
      "_meta": {
        "title": "TTS Generation"
      }
    },
    "51": {
      "inputs": {
        "voice_name": "Morgan_Freeman CC3.wav",
        "reference_text": ""
      },
      "class_type": "CharacterVoicesNode",
      "_meta": {
        "title": "Character Voices"
      }
    },
    "123": {
      "inputs": {
        "emotion_control": ["125", 0]
      },
      "class_type": "IndexTTSEngineNode",
      "_meta": {
        "title": "IndexTTS Engine"
      }
    },
    "125": {
      "inputs": {
        "Happy": 0.25,
        "Angry": 0,
        "Sad": 0.1,
        "Surprised": 0,
        "Afraid": 0,
        "Disgusted": 0,
        "Calm": 0.8,
        "Melancholic": 0
      },
      "class_type": "IndexTTSEmotionOptionsNode",
      "_meta": {
        "title": "IndexTTS-2 Emotion Meters"
      }
    },
    "SaveAudio": {
      "inputs": {
        "audio": ["47", 0],
        "filename_prefix": "tts_output"
      },
      "class_type": "SaveAudio",
      "_meta": {
        "title": "Save Audio"
      }
    }
  },
  "client_id": "n8n_batch_{{ $now.toMillis() }}"
}
```

**Saída deste nó:**
```json
{
  "prompt_id": "5eec4c5d-d85a-418f-b255-011002c2ee50",
  "number": 85,
  "node_errors": {}
}
```

---

### Nó 2: Wait for Generation (Wait)

**Nome:** `Wait for Generation`

**Configuração:**
- **Resume:** After Time Interval
- **Wait Amount:** 5 (ou mais, dependendo do tamanho do texto)
- **Unit:** Seconds

**Objetivo:** Dar tempo para o ComfyUI processar o áudio antes de buscar o resultado.

---

### Nó 3: Get ComfyUI History (HTTP Request)

**Nome:** `Get ComfyUI History`

**Configuração:**
- **Method:** GET
- **URL:** `http://host.docker.internal:8001/history/{{ $('ComfyUI - Execute TTS').item.json.prompt_id }}`
- **Authentication:** None
- **Send Body:** No

**Saída deste nó:**
```json
{
  "5eec4c5d-d85a-418f-b255-011002c2ee50": {
    "prompt": [...],
    "outputs": {
      "SaveAudio": {
        "audio": [
          {
            "filename": "tts_output_00001.wav",
            "subfolder": "",
            "type": "output"
          }
        ]
      }
    },
    "status": {
      "status_str": "success",
      "completed": true
    }
  }
}
```

---

### Nó 4: Download Audio (HTTP Request) - OPCIONAL

**Nome:** `Download Audio File`

**Configuração:**
- **Method:** GET
- **URL:**
```
http://host.docker.internal:8001/view?filename={{ $json[$('ComfyUI - Execute TTS').item.json.prompt_id].outputs.SaveAudio.audio[0].filename }}&type=output
```
- **Authentication:** None
- **Response Format:** File

**Saída:** Arquivo de áudio WAV baixado

---

## Simplificação do Workflow

### Estrutura Mínima de Entrada

O wrapper agora adiciona automaticamente os parâmetros faltantes. Você só precisa enviar:

```json
{
  "comfy_workflow": {
    "47": {
      "inputs": {
        "TTS_engine": ["123", 0],
        "opt_narrator": ["51", 0],
        "text": "Seu texto aqui",
        "seed": 3962542152,
        "enable_chunking": true,
        "max_chars_per_chunk": 400,
        "chunk_combination_method": "auto",
        "silence_between_chunks_ms": 100,
        "enable_audio_cache": true,
        "batch_size": 0
      },
      "class_type": "UnifiedTTSTextNode"
    },
    "51": {
      "inputs": {
        "voice_name": "Morgan_Freeman CC3.wav"
      },
      "class_type": "CharacterVoicesNode"
    },
    "123": {
      "inputs": {
        "emotion_control": ["125", 0]
      },
      "class_type": "IndexTTSEngineNode"
    },
    "125": {
      "inputs": {
        "Happy": 0.25,
        "Angry": 0,
        "Sad": 0.1,
        "Surprised": 0,
        "Afraid": 0,
        "Disgusted": 0,
        "Calm": 0.8,
        "Melancholic": 0
      },
      "class_type": "IndexTTSEmotionOptionsNode"
    },
    "SaveAudio": {
      "inputs": {
        "audio": ["47", 0],
        "filename_prefix": "output"
      },
      "class_type": "SaveAudio"
    }
  },
  "client_id": "n8n_client"
}
```

O wrapper adiciona automaticamente:
- ✅ `voices_examples/` ao nome da voz
- ✅ Todos os parâmetros do IndexTTS Engine (model_path, temperature, etc.)
- ✅ `narrator_voice: "none"` no nó de TTS

---

## Vozes Disponíveis

Você pode usar estas vozes (apenas o nome do arquivo):

- `Morgan_Freeman CC3.wav`
- `David_Attenborough CC3.wav`
- `Clint_Eastwood CC3 (enhanced2).wav`
- `Sophie_Anderson CC3.wav`
- `female/female_01.wav`
- `female/female_02.wav`
- `male/male_01.wav`
- `male/male_02.wav`

O wrapper adiciona automaticamente o prefixo `voices_examples/`.

---

## Controle de Emoções

Ajuste as emoções no nó `125`:

```json
{
  "Happy": 0.25,      // Felicidade (0-2)
  "Angry": 0,         // Raiva (0-2)
  "Sad": 0.1,         // Tristeza (0-2)
  "Surprised": 0,     // Surpresa (0-2)
  "Afraid": 0,        // Medo (0-2)
  "Disgusted": 0,     // Desgosto (0-2)
  "Calm": 0.8,        // Calma (0-2)
  "Melancholic": 0    // Melancolia (0-2)
}
```

Valores recomendados: 0 a 1 (valores acima de 1 intensificam a emoção).

---

## Endpoints do Wrapper

### POST /prompt
Envia um workflow para o ComfyUI processar.

**Request:**
```json
{
  "prompt": "{...workflow JSON...}",
  "client_id": "n8n_client"
}
```

**Response:**
```json
{
  "prompt_id": "uuid",
  "number": 85,
  "node_errors": {}
}
```

### GET /history/{prompt_id}
Obtém o histórico e resultado de uma execução.

**Response:**
```json
{
  "prompt_id": {
    "outputs": {
      "SaveAudio": {
        "audio": [
          {
            "filename": "output.wav",
            "subfolder": "",
            "type": "output"
          }
        ]
      }
    },
    "status": {
      "status_str": "success",
      "completed": true
    }
  }
}
```

### GET /view
Baixa um arquivo gerado pelo ComfyUI.

**Query Parameters:**
- `filename`: Nome do arquivo (ex: `output_00001.wav`)
- `type`: Tipo de arquivo (padrão: `output`)
- `subfolder`: Subpasta (opcional)

**Example:**
```
http://host.docker.internal:8001/view?filename=output_00001.wav&type=output
```

### GET /health
Verifica o status do wrapper e do ComfyUI.

**Response:**
```json
{
  "status": "running",
  "comfyui": "online",
  "comfyui_url": "http://127.0.0.1:8000"
}
```

---

## Troubleshooting

### Erro: "The service refused the connection"
- Verifique se o wrapper está rodando: `python api_wrapper.py`
- Confirme que está usando `host.docker.internal:8001` (não `localhost` ou `127.0.0.1`)

### Erro: "ComfyUI returned an error"
- Verifique os logs do wrapper para ver o erro específico
- Confirme que o ComfyUI está rodando na porta 8000

### Áudio não é gerado
- Aumente o tempo de espera no nó "Wait for Generation"
- Verifique os logs do ComfyUI para erros de processamento
- Use o endpoint `/history/{prompt_id}` para verificar o status

### Nome de voz inválido
- Use apenas o nome do arquivo (ex: `Morgan_Freeman CC3.wav`)
- Não adicione o prefixo `voices_examples/` manualmente
- Consulte a lista de vozes disponíveis acima

---

## Exemplo Completo de Workflow n8n (JSON)

Para importar no n8n, crie um workflow com esta estrutura:

1. **Manual Trigger** → para iniciar o workflow manualmente
2. **Set** → define o JSON do workflow ComfyUI
3. **HTTP Request (Execute TTS)** → envia para o wrapper
4. **Wait** → aguarda processamento
5. **HTTP Request (Get History)** → busca resultado
6. **HTTP Request (Download Audio)** → baixa o arquivo (opcional)

---

## Próximos Passos

- ✅ Integrar com banco de dados para salvar histórico
- ✅ Adicionar webhook para notificação quando o áudio estiver pronto
- ✅ Criar endpoint para listar todas as vozes disponíveis
- ✅ Adicionar suporte para batch processing (múltiplos textos)
