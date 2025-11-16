# 🎙️ ComfyUI IndexTTS-2 Integration System

Sistema completo de integração para geração de áudio TTS usando ComfyUI IndexTTS-2, n8n e API Wrapper.

## ✨ Características

- 🔄 **API Wrapper** - Converte formatos entre n8n e ComfyUI automaticamente
- 🎭 **Controle de Emoções** - Suporte para 8 emoções diferentes (Happy, Sad, Angry, etc.)
- 🗣️ **Múltiplas Vozes** - Suporte para várias vozes pré-treinadas
- 🐳 **Docker Integration** - n8n e wrapper rodando em containers
- 🚀 **Auto-start** - Scripts para inicialização automática no Windows
- 📊 **Workflow Automation** - Integração completa com n8n

## 🎯 Problema que Resolve

O n8n (rodando no Docker) não consegue se comunicar diretamente com o ComfyUI (rodando no Windows) devido a:
1. Diferenças de formato JSON (string vs objeto)
2. Parâmetros obrigatórios faltando
3. Problemas de rede entre Docker e host Windows

Este sistema resolve tudo isso automaticamente!

## 🚀 Início Rápido

### Instalação Completa

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/comfyui-tts-integration
cd comfyui-tts-integration

# 2. Configure variáveis de ambiente
copy .env.example .env
# Edite .env com suas credenciais

# 3. Inicie todo o sistema
start_all.bat
```

### Primeira Execução

1. **Inicie o ComfyUI** (em terminal separado):
   ```bash
   start_comfyui.bat
   ```

2. **Inicie os serviços Docker**:
   ```bash
   start_all.bat
   ```

3. **Acesse o n8n**:
   - URL: http://localhost:5678
   - Credenciais: definidas no arquivo `.env`

4. **Teste o sistema**:
   ```bash
   curl http://localhost:8001/health
   ```

## 📚 Documentação

- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Guia completo de instalação e configuração
- **[N8N_WORKFLOW_GUIDE.md](N8N_WORKFLOW_GUIDE.md)** - Como criar workflows no n8n
- **[test_examples.json](test_examples.json)** - Exemplos de teste com múltiplas emoções

## Endpoints disponíveis

- `POST /prompt` - Processa requisições de TTS e encaminha para o ComfyUI
- `GET /health` - Verifica status do wrapper e do ComfyUI
- `GET /history/<prompt_id>` - Obtém histórico de uma requisição

## Verificação

Para testar se está funcionando:

```bash
curl http://localhost:8001/health
```

Deve retornar:
```json
{
  "status": "running",
  "comfyui": "online",
  "comfyui_url": "http://127.0.0.1:8000"
}
```

## Arquitetura

```
n8n (Docker) → wrapper (porta 8001) → ComfyUI (porta 8000)
     ↓                ↓                      ↓
  Envia JSON      Converte            Processa TTS
  stringificado   formato             e retorna áudio
```

## Endpoints Disponíveis

### POST /prompt
Envia workflow para processar TTS
- Converte automaticamente JSON stringificado para objeto
- Adiciona parâmetros faltantes (voice path, engine params, etc.)

### GET /history/{prompt_id}
Obtém histórico e resultado de uma execução

### GET /view?filename=X&type=output
Baixa arquivos de áudio gerados pelo ComfyUI

### GET /health
Verifica status do wrapper e do ComfyUI

## Guia Completo de Uso

Para um guia detalhado de como usar com n8n, veja [N8N_WORKFLOW_GUIDE.md](N8N_WORKFLOW_GUIDE.md)
