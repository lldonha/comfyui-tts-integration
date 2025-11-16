# Gemini Integration Guide - Rev 2

## Visão Geral

A **Rev 2** do workflow adiciona integração completa com:
- 📧 **Email Trigger** - Recebe prompts por email
- 🤖 **Gemini API** - Expande prompts curtos em histórias completas
- 🎙️ **TTS Processing** - Gera áudio com emoções
- 🎵 **Audio Concatenation** - Junta todos os segmentos
- ✉️ **Email Notification** - Envia link de download

## Fluxo Completo

```
Email com prompt curto
    ↓
Gemini expande para história completa (~45s)
    ↓
Divide em 3-8 segmentos
    ↓
Loop TTS (gera áudio de cada segmento)
    ↓
Concatena áudios com FFmpeg
    ↓
Envia email com link de download
```

## Configuração

### 1. Obter Gemini API Key

1. Acesse: https://makersuite.google.com/app/apikey
2. Crie um novo projeto (se necessário)
3. Clique em "Get API Key"
4. Copie a chave

### 2. Configurar Email (Gmail)

**Para Gmail:**

1. Habilite verificação em 2 etapas: https://myaccount.google.com/security
2. Crie uma senha de app:
   - Acesse: https://myaccount.google.com/apppasswords
   - Selecione "Email" e "Windows Computer"
   - Copie a senha gerada (16 caracteres)

3. Use essas credenciais no n8n:
   - **IMAP** (receber emails):
     - Host: `imap.gmail.com`
     - Port: `993`
     - SSL/TLS: Sim
   - **SMTP** (enviar emails):
     - Host: `smtp.gmail.com`
     - Port: `587`
     - SSL/TLS: Sim

### 3. Configurar Variáveis de Ambiente

Copie `.env.example` para `.env`:

```bash
cp .env.example .env
```

Edite `.env` e preencha:

```env
# Gemini API
GEMINI_API_KEY=sua_chave_aqui
GEMINI_MODEL=gemini-1.5-flash

# Email
EMAIL_IMAP_HOST=imap.gmail.com
EMAIL_IMAP_PORT=993
EMAIL_USER=seu_email@gmail.com
EMAIL_PASSWORD=sua_senha_de_app_16_chars

# Output
OUTPUT_DIR=./output
FINAL_AUDIO_DIR=./final_audio
```

### 4. Importar Workflow no n8n

1. Acesse n8n: http://localhost:5678
2. Clique em "Add workflow" → "Import from file"
3. Selecione: `workflow_rev2_email_gemini.json`
4. Configure as credenciais:

**Credential 1: Gmail IMAP**
- Name: `Gmail IMAP`
- Type: `IMAP`
- Host: `imap.gmail.com`
- Port: `993`
- User: `seu_email@gmail.com`
- Password: `sua_senha_de_app`
- SSL/TLS: `Enabled`

**Credential 2: Gemini API Key**
- Name: `Gemini API Key`
- Type: `HTTP Query Auth`
- Name: `key`
- Value: `sua_gemini_api_key`

**Credential 3: Gmail SMTP**
- Name: `Gmail SMTP`
- Type: `SMTP`
- Host: `smtp.gmail.com`
- Port: `587`
- User: `seu_email@gmail.com`
- Password: `sua_senha_de_app`
- SSL/TLS: `Enabled`

5. Ative o workflow

## Como Usar

### Método 1: Email com Prompt no Subject

Envie email para a conta configurada:

```
Subject: terror no cemitério à noite
Body: [pode ficar vazio]
```

### Método 2: Email com [TTS] tag

```
Subject: [TTS] História de terror
Body: Um garoto encontra um livro amaldiçoado em uma biblioteca abandonada
```

### Método 3: Email com Prompt Longo

```
Subject: Nova história
Body: Era uma noite escura quando Maria decidiu explorar a casa
abandonada no fim da rua. As janelas estavam quebradas e a porta
range ao abrir...
```

O Gemini vai:
1. Receber o prompt
2. Expandir em narrativa completa
3. Adicionar ambientação, suspense e twist
4. Dividir em 3-8 segmentos de ~45s total
5. Definir vozes e emoções adequadas

## Estrutura de Output do Gemini

```json
{
  "title": "A Casa Assombrada",
  "genre": "terror",
  "total_duration_estimate": "48s",
  "batch_id": "casa_assombrada",
  "segments": [
    {
      "segment_number": 1,
      "scene_type": "opening",
      "text": "Maria parou em frente à casa abandonada...",
      "voice": "Morgan_Freeman CC3.wav",
      "emotions": {
        "Calm": 0.6,
        "Melancholic": 0.8
      },
      "duration_estimate": "8s"
    }
  ]
}
```

## Vozes Disponíveis

- **Morgan_Freeman CC3.wav** - Narrador profundo e calmo (use para narração principal)
- **Freddy Krueger CC3.wav** - Voz sinistra e ameaçadora (antagonistas/momentos tensos)
- **HAL 9000 CC3.wav** - Voz fria e robótica (efeitos especiais)

## Emoções Disponíveis

Valores de 0 a 1.2:

- **Happy** - Alegria/leveza
- **Angry** - Raiva/intensidade
- **Sad** - Tristeza/melancolia
- **Surprised** - Surpresa/choque
- **Afraid** - Medo/terror
- **Disgusted** - Repulsa/nojo
- **Calm** - Calma/serenidade
- **Melancholic** - Melancólico/sombrio

## Tipos de Cena

- `opening` - Abertura/ambientação
- `buildup` - Construção de tensão
- `tension` - Momento de suspense
- `climax` - Pico da história
- `twist` - Revelação/surpresa
- `ending` - Desfecho

## Processamento

### 1. Email Trigger (a cada minuto)
- Verifica novos emails na pasta INBOX
- Marca como lido após processar

### 2. Extract Prompt
- Extrai prompt do subject ou body
- Remove assinaturas de email
- Remove Re:/Fwd:

### 3. Gemini API
- Envia prompt com template completo
- Temperature: 0.9 (criatividade)
- Max tokens: 2048

### 4. Parse Gemini Response
- Extrai JSON da resposta
- Remove markdown se presente
- Valida estrutura

### 5. Split Scenes
- Divide história em segmentos
- Prepara dados para TTS

### 6. Loop TTS
- Processa cada segmento individualmente
- Gera áudio com emoções
- Aguarda 12s entre cada

### 7. Aggregate Results
- Coleta todos os áudios gerados
- Ordena por segment_index
- Prepara lista para concatenação

### 8. Concatenate Audio
- Usa FFmpeg para juntar áudios
- Adiciona 500ms de silêncio entre segmentos
- Salva em `final_audio/{batch_id}_final.wav`

### 9. Send Email Notification
- Envia email com link de download
- Inclui metadados (duração, segmentos)

## Diretórios

```
api_tts/
├── final_audio/           # Áudios finais concatenados
│   └── {batch_id}_final.wav
├── temp/                  # Arquivos temporários
│   └── concat_{batch_id}.txt
└── output/                # Áudios individuais (via ComfyUI)
    └── {batch_id}_01_opening.wav
```

## Troubleshooting

### Email não está sendo processado

1. Verifique se o workflow está ativo (toggle verde)
2. Confira as credenciais IMAP
3. Veja os logs do workflow (clique em "Executions")

### Gemini retorna erro

1. Verifique se a API key está correta
2. Confira se há quota disponível: https://console.cloud.google.com/
3. Veja o rate limit (1500 requests/dia no free tier)

### FFmpeg falha na concatenação

1. Instale FFmpeg: https://ffmpeg.org/download.html
2. Adicione ao PATH do Windows
3. Teste: `ffmpeg -version`

### Áudio final não é criado

1. Verifique se todos os segmentos foram gerados
2. Confira o diretório ComfyUI output
3. Veja logs do node "Concatenate Audio"

## Exemplo Completo

**Email enviado:**
```
Subject: [TTS] Elevador
Body: Um elevador que para no 13º andar que não existe
```

**Gemini expande para:**
```json
{
  "title": "O 13º Andar",
  "batch_id": "o_13_andar",
  "segments": [
    {
      "segment_number": 1,
      "text": "João entrou no elevador vazio do prédio comercial...",
      "voice": "Morgan_Freeman CC3.wav",
      "emotions": {"Calm": 0.8}
    },
    {
      "segment_number": 2,
      "text": "Ele apertou o botão do 10º andar, mas o elevador...",
      "voice": "Morgan_Freeman CC3.wav",
      "emotions": {"Surprised": 0.6, "Afraid": 0.3}
    },
    {
      "segment_number": 3,
      "text": "As portas se abriram. Um corredor infinito, iluminado...",
      "voice": "Morgan_Freeman CC3.wav",
      "emotions": {"Afraid": 0.9, "Melancholic": 0.7}
    },
    {
      "segment_number": 4,
      "text": "Uma voz sussurrou: 'Bem-vindo ao andar que não existe'...",
      "voice": "Freddy Krueger CC3.wav",
      "emotions": {"Angry": 1.0, "Disgusted": 0.8}
    },
    {
      "segment_number": 5,
      "text": "João nunca mais foi visto. Mas dizem que o elevador...",
      "voice": "Morgan_Freeman CC3.wav",
      "emotions": {"Melancholic": 1.2, "Calm": 0.4}
    }
  ]
}
```

**Resultado:**
- 5 áudios individuais gerados
- Concatenados em: `final_audio/o_13_andar_final.wav`
- Email enviado com link de download
- Duração total: ~42s

## Performance

- **Email check**: A cada 1 minuto
- **Gemini API**: ~2-5 segundos
- **TTS por segmento**: ~12-15 segundos
- **Concatenação**: ~1-2 segundos
- **Total (5 segmentos)**: ~2-3 minutos

## Custos

- **Gemini API (free tier)**:
  - 1500 requests/dia
  - ~60 histórias/dia

- **Gmail**:
  - Gratuito (limite: 500 emails/dia)

- **ComfyUI + n8n**:
  - Self-hosted (gratuito)

## Próximos Passos (Rev 3)

- [ ] Adicionar música de fundo
- [ ] Efeitos sonoros (trovão, porta rangendo)
- [ ] Upload automático para YouTube/TikTok
- [ ] Interface web para visualizar histórias
- [ ] Suporte a múltiplos idiomas
- [ ] Geração de legendas (SRT)
