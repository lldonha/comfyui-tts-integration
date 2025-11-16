# Guia de Configuração Completo

## Sistema TTS ComfyUI + n8n + API Wrapper

Este guia mostra como configurar todo o sistema para rodar automaticamente na inicialização do Windows.

---

## 📋 Pré-requisitos

1. **Docker Desktop** instalado e configurado
2. **ComfyUI** instalado em `E:\CONFY` (ou ajuste os caminhos)
3. **Git** instalado (para versionamento)
4. **Python 3.12+** (já instalado com ComfyUI)

---

## 🚀 Instalação Rápida

### 1. Clone ou Prepare o Repositório

```bash
cd e:\api_tts
git init
```

### 2. Configure as Variáveis de Ambiente

```bash
copy .env.example .env
```

Edite o `.env` e ajuste as senhas:
```
N8N_USER=seu_usuario
N8N_PASSWORD=sua_senha_segura
```

### 3. Inicie o Sistema

Execute o arquivo:
```
start_all.bat
```

Isso vai iniciar:
- ✅ n8n (porta 5678)
- ✅ API Wrapper (porta 8001)

**Nota:** O ComfyUI deve ser iniciado separadamente no Windows (veja abaixo).

---

## 🔧 Configuração de Inicialização Automática

### Passo 1: Configurar Docker Desktop

1. Abra Docker Desktop
2. Vá em **Settings** → **General**
3. Marque: **"Start Docker Desktop when you log in"**
4. Clique em **Apply & Restart**

### Passo 2: Configurar Inicialização Automática do Sistema

Execute como Administrador:
```
setup_startup.bat
```

Isso criará um atalho na pasta de inicialização do Windows.

### Passo 3: Configurar ComfyUI para Iniciar Automaticamente

#### Opção A: Task Scheduler (Recomendado)

1. Pressione `Win + R` e digite `taskschd.msc`
2. Clique em **"Create Task"**
3. Configure:
   - **Name:** ComfyUI Startup
   - **Triggers:** At log on (of specific user)
   - **Actions:** Start a program
     - Program: `E:\api_tts\start_comfyui.bat`
   - **Conditions:** Desmarque "Start only if on AC power"
4. Clique em **OK**

#### Opção B: Atalho na Pasta de Inicialização

1. Pressione `Win + R`
2. Digite `shell:startup`
3. Arraste `start_comfyui.bat` para a pasta
4. Selecione "Create shortcut here"

---

## 📊 Arquitetura do Sistema

```
┌─────────────────────────────────────────────┐
│           Windows (Host Machine)            │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │       ComfyUI (porta 8000)          │   │
│  │   - IndexTTS-2 Engine               │   │
│  │   - Audio Generation                │   │
│  └─────────────────────────────────────┘   │
│                    ▲                        │
│                    │                        │
│  ┌─────────────────────────────────────┐   │
│  │   Docker Compose (Network Bridge)   │   │
│  │                                     │   │
│  │  ┌───────────────────────────────┐ │   │
│  │  │  API Wrapper (porta 8001)     │ │   │
│  │  │  - Converte formatos          │ │   │
│  │  │  - Adiciona parâmetros        │ │   │
│  │  │  - Proxy para ComfyUI         │ │   │
│  │  └───────────────────────────────┘ │   │
│  │                ▲                   │   │
│  │                │                   │   │
│  │  ┌───────────────────────────────┐ │   │
│  │  │      n8n (porta 5678)         │ │   │
│  │  │  - Workflow Automation        │ │   │
│  │  │  - API Orchestration          │ │   │
│  │  └───────────────────────────────┘ │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

---

## 🔍 Verificação

Após iniciar tudo, verifique se os serviços estão rodando:

### 1. Docker Services
```bash
docker-compose ps
```

Deve mostrar:
```
NAME                STATUS
comfyui_wrapper     Up
n8n                 Up
```

### 2. Endpoints

- **n8n:** http://localhost:5678
  - User: (definido no .env)
  - Password: (definido no .env)

- **API Wrapper Health:** http://localhost:8001/health
  - Deve retornar: `{"status": "running", "comfyui": "online"}`

- **ComfyUI:** http://localhost:8000
  - Interface web do ComfyUI

---

## 🎯 Testando o Sistema

### Teste Simples via cURL

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

### Teste com n8n

1. Acesse http://localhost:5678
2. Faça login com as credenciais do `.env`
3. Importe o workflow de exemplo
4. Execute e verifique os resultados

---

## 📝 Exemplos de Teste

Veja `test_examples.json` para exemplos de:

1. **Horror Story** - Múltiplas emoções dramáticas
2. **Comedy Sketch** - Emoções alegres e surpresas
3. **Documentary** - Tom calmo e educativo
4. **Emotional Rollercoaster** - Todas as emoções em sequência

---

## 🛑 Parar o Sistema

Para parar todos os serviços Docker:
```
stop_all.bat
```

Para parar o ComfyUI:
- Feche a janela do terminal ou pressione `Ctrl+C`

---

## 🔄 Atualizar o Sistema

### Atualizar código:
```bash
git pull
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Ver logs:
```bash
docker-compose logs -f
```

---

## 🐛 Troubleshooting

### Docker não inicia
```bash
# Verificar se Docker está rodando
docker info

# Se não estiver, inicie o Docker Desktop manualmente
```

### ComfyUI não conecta
```bash
# Verifique se ComfyUI está rodando na porta 8000
netstat -an | findstr :8000

# Teste conexão direta
curl http://localhost:8000/system_stats
```

### n8n não acessa API Wrapper
```bash
# Verificar logs do wrapper
docker-compose logs api_wrapper

# Testar do host
curl http://localhost:8001/health
```

### Porta já está em uso
```bash
# Ver o que está usando a porta
netstat -ano | findstr :8001

# Matar processo (substitua PID)
taskkill /PID <PID> /F
```

---

## 📂 Estrutura de Arquivos

```
e:\api_tts\
├── api_wrapper.py          # Servidor wrapper
├── requirements.txt        # Dependências Python
├── docker-compose.yml      # Configuração Docker
├── Dockerfile             # Build do wrapper
├── .env                   # Variáveis de ambiente (não commitado)
├── .env.example           # Exemplo de .env
├── .gitignore             # Arquivos ignorados pelo Git
├── start_all.bat          # Inicia Docker services
├── stop_all.bat           # Para Docker services
├── start_comfyui.bat      # Inicia ComfyUI no Windows
├── setup_startup.bat      # Configura inicialização automática
├── test_examples.json     # Exemplos de teste
├── README.md              # Documentação principal
├── N8N_WORKFLOW_GUIDE.md  # Guia de workflows n8n
└── SETUP_GUIDE.md         # Este arquivo
```

---

## 🎓 Próximos Passos

1. ✅ Testar sistema completo
2. ✅ Configurar inicialização automática
3. ✅ Criar workflows personalizados no n8n
4. ✅ Versionar no GitHub
5. ✅ Adicionar monitoramento (opcional)
6. ✅ Configurar backups automáticos (opcional)
