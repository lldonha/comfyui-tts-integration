# 🎬 Guia de Uso: Scene Processor Workflow

Este workflow processa histórias com múltiplas cenas, aplicando emoções diferentes para cada cena.

---

## 📥 Input Format

```json
{
  "batch_id": "test_run_001",
  "voice": "Morgan_Freeman CC3.wav",
  "scenes": [
    {
      "scene_type": "intro",
      "text": "Your scene text here...",
      "emotion_profile": {
        "Happy": 0,
        "Angry": 0,
        "Sad": 0.3,
        "Surprised": 0.4,
        "Afraid": 0.9,
        "Disgusted": 0,
        "Calm": 0.1,
        "Melancholic": 0.4
      }
    }
  ]
}
```

### Campos obrigatórios:
- `batch_id` - ID único para este lote (usado no nome dos arquivos)
- `voice` - Nome da voz (ex: "Morgan_Freeman CC3.wav")
- `scenes` - Array de cenas

### Cada cena deve ter:
- `scene_type` - Tipo da cena (intro, setup, mid, climax, reveal, outro, etc.)
- `text` - Texto a ser narrado (SEM incluir valores de emoção)
- `emotion_profile` - Objeto com 8 emoções (valores 0-2)

---

## 📤 Output Format

O workflow gera um relatório final com:

```json
{
  "batch_id": "test_run_001",
  "total_scenes": 6,
  "successful": 6,
  "failed": 0,
  "success_rate": "100.0%",
  "audio_files": [
    {
      "scene_number": "01",
      "scene_type": "intro",
      "text": "I always thought old houses...",
      "path": "test_run_001_01_intro_00001.wav",
      "download_url": "http://host.docker.internal:8001/view?filename=test_run_001_01_intro_00001.wav&type=output"
    },
    {
      "scene_number": "02",
      "scene_type": "setup",
      "text": "On my first night...",
      "path": "test_run_001_02_setup_00001.wav",
      "download_url": "http://host.docker.internal:8001/view?filename=test_run_001_02_setup_00001.wav&type=output"
    }
  ],
  "timestamp": "2025-11-16T01:30:00.000Z"
}
```

---

## 🎯 Como Usar

### 1. Importar Workflow no n8n

1. Acesse n8n: http://localhost:5678
2. Clique em "Add workflow" → "Import from file"
3. Selecione: `workflow_scene_processor.json`
4. Clique em "Save"

### 2. Preparar Input

Copie o JSON de exemplo e ajuste:
- `batch_id` - Use um ID único (ex: timestamp)
- `voice` - Escolha uma voz disponível
- `scenes` - Adicione suas cenas com textos e emoções

### 3. Executar

1. Cole o JSON no nó "Manual Input"
2. Clique em "Execute Workflow"
3. Aguarde o processamento (≈ 10-15s por cena)
4. Veja o relatório final no último nó

### 4. Baixar Áudios

Use as URLs no campo `download_url` para baixar cada áudio:

```bash
curl -O "http://localhost:8001/view?filename=test_run_001_01_intro_00001.wav&type=output"
```

Ou abra diretamente no navegador.

---

## 🎭 Emoções Disponíveis

| Emoção | Range | Descrição |
|--------|-------|-----------|
| Happy | 0-2 | Felicidade, alegria |
| Angry | 0-2 | Raiva, frustração |
| Sad | 0-2 | Tristeza, melancolia |
| Surprised | 0-2 | Surpresa, choque |
| Afraid | 0-2 | Medo, terror |
| Disgusted | 0-2 | Nojo, repulsa |
| Calm | 0-2 | Calma, serenidade |
| Melancholic | 0-2 | Melancolia, nostalgia |

**Valores recomendados:**
- 0 = Sem emoção
- 0.5-1.0 = Emoção leve
- 1.0-1.5 = Emoção moderada
- 1.5-2.0 = Emoção intensa

---

## 🗣️ Vozes Disponíveis

- `Morgan_Freeman CC3.wav` - Voz grave, narrativa
- `David_Attenborough CC3.wav` - Voz educativa, documentários
- `Clint_Eastwood CC3 (enhanced2).wav` - Voz rouca, western
- `Sophie_Anderson CC3.wav` - Voz feminina, jovem
- `male/male_01.wav` - Voz masculina genérica 1
- `male/male_02.wav` - Voz masculina genérica 2
- `female/female_01.wav` - Voz feminina genérica 1
- `female/female_02.wav` - Voz feminina genérica 2

---

## 📋 Exemplo Completo: Horror Story

```json
{
  "batch_id": "horror_house_001",
  "voice": "Morgan_Freeman CC3.wav",
  "scenes": [
    {
      "scene_type": "intro",
      "text": "I always thought old houses creaked because of age. But this one… it creaked when you whispered. As if it whispered back.",
      "emotion_profile": {
        "Happy": 0,
        "Angry": 0,
        "Sad": 0.3,
        "Surprised": 0.4,
        "Afraid": 0.9,
        "Disgusted": 0,
        "Calm": 0.1,
        "Melancholic": 0.4
      }
    },
    {
      "scene_type": "setup",
      "text": "On my first night, I heard someone walking upstairs. Slow. Heavy. One step at a time. Except… I live alone.",
      "emotion_profile": {
        "Happy": 0,
        "Angry": 0,
        "Sad": 0.2,
        "Surprised": 0.6,
        "Afraid": 1.0,
        "Disgusted": 0,
        "Calm": 0,
        "Melancholic": 0.3
      }
    },
    {
      "scene_type": "climax",
      "text": "The walls pulsed. The floorboards trembled. A low groan rose beneath my feet, as if something enormous was waking up… hungry.",
      "emotion_profile": {
        "Happy": 0,
        "Angry": 0.1,
        "Sad": 0,
        "Surprised": 0.5,
        "Afraid": 1.0,
        "Disgusted": 0.4,
        "Calm": 0,
        "Melancholic": 0
      }
    },
    {
      "scene_type": "outro",
      "text": "Now every time I speak, the house answers. And every time it does… the whisper sounds closer. Tonight, it sounded like it was inside my own mouth.",
      "emotion_profile": {
        "Happy": 0,
        "Angry": 0,
        "Sad": 0.4,
        "Surprised": 0.4,
        "Afraid": 1.0,
        "Disgusted": 0.1,
        "Calm": 0,
        "Melancholic": 0.4
      }
    }
  ]
}
```

---

## 🔧 Troubleshooting

### Problema: "No audio output found"
**Solução:** Aumente o tempo de espera no nó "Wait for Generation" (de 5s para 10s)

### Problema: Áudio cortado
**Solução:** Verifique se `max_chars_per_chunk` está adequado (padrão: 400)

### Problema: Emoções não aplicadas
**Solução:** Verifique se os valores estão corretos (0-2) e se todos os 8 campos existem

### Problema: Arquivo não encontrado
**Solução:** Verifique se o ComfyUI está rodando e se o output directory está acessível

---

## 📊 Estatísticas de Tempo

| Cenas | Tempo Estimado |
|-------|----------------|
| 1 cena | ~10-15s |
| 3 cenas | ~30-45s |
| 6 cenas | ~60-90s |
| 10 cenas | ~100-150s |

**Nota:** Depende do tamanho do texto e da complexidade das emoções.

---

## 🎓 Dicas Avançadas

### Variando Vozes por Cena

Modifique o nó "Build ComfyUI Workflow" para aceitar `voice` por cena:

```javascript
"voice_name": scene.voice || item.voice
```

E no input:
```json
{
  "scene_type": "intro",
  "voice": "Morgan_Freeman CC3.wav",
  "text": "...",
  "emotion_profile": {...}
}
```

### Seeds Fixas para Reprodutibilidade

Adicione `seed` por cena:
```json
{
  "scene_type": "intro",
  "seed": 123456,
  "text": "...",
  "emotion_profile": {...}
}
```

### Pausas Entre Cenas

Adicione `silence_after_ms` para controlar pausas:
```json
{
  "scene_type": "intro",
  "silence_after_ms": 1000,
  "text": "...",
  "emotion_profile": {...}
}
```

---

## 📝 Changelog

### v1.0.0 (2025-11-16)
- ✅ Workflow inicial criado
- ✅ Suporte para múltiplas cenas
- ✅ Nomenclatura organizada de arquivos
- ✅ Relatório final com estatísticas
- ✅ Extração correta de texto (sem valores de emoção)
