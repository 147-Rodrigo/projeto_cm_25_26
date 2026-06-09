# EcoLoop 

Aplicação mobile desenvolvida em **Flutter** com backend **Firebase**, que tem como objetivo promover a sustentabilidade e a cidadania ambiental. A app permite aos utilizadores consultar um mapa interativo de pontos ecológicos, participar em eventos comunitários, fazer doações a ONGs, aceder a notícias ambientais e interagir num fórum.

---

## Índice

- [Funcionalidades](#funcionalidades)
- [Arquitetura e Estrutura do Projeto](#arquitetura-e-estrutura-do-projeto)
- [Ecrãs e Navegação](#ecrãs-e-navegação)
- [Serviços Firebase](#serviços-firebase)
- [Serviços Internos](#serviços-internos)
- [Requisitos e Instalação](#requisitos-e-instalação)
- [Configuração Firebase](#configuração-firebase)
- [Permissões](#permissões)

---

## Funcionalidades

### Autenticação
- Registo de conta com nome, email, password, data de nascimento e localização
- Login com email e password via Firebase Authentication
- Edição de perfil (nome, data de nascimento, localização) através de um bottom sheet
- Terminar sessão

### Mapa Interativo (Google Maps)
- Mapa centrado na região de Setúbal (lat: 38.52, lng: -8.84)
- Marcadores de pontos eco-friendly (ecopontos, lojas sustentáveis, etc.)
- Definir ponto de **origem** (long press no mapa)
- Selecionar **destino** clicando num marcador
- Traçar rota com polyline azul entre origem e destino (via Google Directions API)
- Mostrar distância total e duração da rota
- Botões para centrar câmara na origem ou destino
- Botão para limpar rota
- No modo web, é exibida uma mensagem informativa em alternativa ao mapa

### Eventos
- Listagem em tempo real (Firestore stream) de eventos comunitários
- Cada evento apresenta: título, autor, data, hora de início e fim, local, descrição, materiais necessários, categoria e número de inscritos
- **Criar evento**: título, descrição, local, materiais, máximo de participantes, data (date picker), hora de início e fim (time picker), categoria (Limpeza, Reciclagem, Plantação, Educação, Outro)
- **Editar e apagar evento** (apenas o autor)
- **Inscrição/cancelamento** em eventos (com verificação de lotação)
- Badge de categoria e contador de participantes por evento

### Doações
- Listagem das ONGs parceiras:
  - Cáritas Portuguesa
  - Banco Alimentar Contra a Fome
  - Comunidade Vida e Paz
  - Santa Casa da Misericórdia
  - Cruz Vermelha Portuguesa
  - Liga dos Bombeiros Portugueses
- Cada card é expansível: ao clicar, abre um painel com grelha de valores (10€, 20€, 40€, 60€, 80€, 100€)
- Seleção de valor com destaque visual
- Botão "Doar" que se ativa apenas após seleção de valor
- Pop-up de confirmação com ícone, valor doado, nome da ONG e mensagem de agradecimento

### Notícias
- Feed de notícias ambientais em tempo real (Firestore stream)
- Cada notícia apresenta: imagem (URL), categoria, título, descrição resumida, fonte e data de publicação
- Botão "Ler mais" que abre o artigo completo
- **Modo Admin**: utilizadores com `role == 'admin'` podem adicionar, editar e apagar notícias
- Criação/edição de notícia inclui: título, descrição, artigo completo, fonte, categoria (Geral, Reciclagem, Clima, Energia, Biodiversidade, Comunidade, Outro) e URL de imagem com pré-visualização
- Ao publicar uma nova notícia, é criada automaticamente uma notificação no Firestore

### Fórum
- Ecrã de comunidade com publicações estáticas de utilizadores
- Cada publicação apresenta nome do utilizador, data e texto

### Notificações
- Listagem de notificações em tempo real (Firestore stream, coleção `notifications`)
- Notificações push locais via `flutter_local_notifications` ao receber novos documentos na coleção

### Perfil
- Visualização dos dados do utilizador (email, nome, data de nascimento, localização)
- Edição de perfil inline com bottom sheet
- Botão de terminar sessão

### Guia / Info
- Secção informativa com cards sobre: ecopontos, lojas sustentáveis, cafés pet-friendly, dicas ecológicas, mapa verde, eventos e doações

---

## Arquitetura e Estrutura do Projeto

```
lib/
├── API/
│   └── maps.dart                   # Widget Google Maps com rotas
├── Style/
│   ├── custom_appbar.dart          # AppBar reutilizável
│   ├── mapa_style.dart             # Estilos do mapa
│   ├── profile_styles.dart         # Estilos do perfil
│   └── text_styles.dart            # Estilos de texto globais
├── data/
│   └── places_data.dart            # Dados estáticos dos pontos no mapa
├── models/
│   └── place_point.dart            # Modelo de ponto no mapa
├── services/
│   ├── auth_service.dart           # Registo, login, edição de perfil
│   ├── event_service.dart          # CRUD de eventos e inscrições
│   ├── admin_service.dart          # Verificação de role admin
│   ├── notification_service.dart   # Criação de notificações no Firestore
│   ├── LocalNotificationService.dart # Notificações push locais
│   ├── markers_service.dart        # Geração de marcadores do mapa
│   ├── directions_repository.dart  # Chamadas à Google Directions API
│   ├── directions_model.dart       # Modelo de resposta de direções
│   └── .env.dart                   # Chaves de API (não incluir no git)
├── adicionar_noticia.dart          # Formulário criar/editar notícia (admin)
├── adicionar_evento.dart           # (auxiliar de eventos)
├── criar_evento.dart               # Formulário criar/editar evento
├── donation.dart                   # Ecrã de doações com seleção de valor
├── evento_detalhe.dart             # Detalhe de evento
├── eventos.dart                    # Listagem de eventos
├── firebase_options.dart           # Configuração Firebase (gerado)
├── forum.dart                      # Ecrã do fórum
├── home.dart                       # Ecrã principal com mapa
├── info.dart                       # Ecrã guia/informação
├── limpar_noticias.dart            # Utilitário admin
├── login.dart                      # Ecrã de login
├── main.dart                       # Ponto de entrada, inicialização Firebase
├── models/                         # (ver acima)
├── noticia_detalhe.dart            # Detalhe de notícia
├── noticias.dart                   # Feed de notícias
├── notificacoes.dart               # Ecrã de notificações
├── perfil.dart                     # Ecrã de perfil
└── registo.dart                    # Ecrã de registo
```

---

## Ecrãs e Navegação

A app usa navegação `push`/`pop` com `MaterialPageRoute`. Todos os ecrãs principais partilham uma **barra de navegação inferior** com 5 ícones:

| Ícone | Destino |
|---|---|
| 🗺️ Mapa | `HomePage` |
| 📅 Eventos | `EventosPage` |
| 💚 Doações | `DonationPage` |
| 💬 Fórum | `ForumPage` |
| ℹ️ Guia | `InfoPage` |

A **AppBar** de cada ecrã contém atalhos para Notícias, Notificações e Perfil.

### Fluxo de início
```
StartPage (logo + botões)
    ├── LoginPage  ──▶  HomePage
    └── RegistoPage ──▶ StartPage
```

---

## Serviços Firebase

| Serviço | Utilização |
|---|---|
| **Firebase Auth** | Registo e login com email/password |
| **Cloud Firestore** | Utilizadores, eventos, notícias, notificações |
| **Firebase Core** | Inicialização da app |

### Coleções Firestore

**`users`**
```
{
  nome: String,
  email: String,
  dataNascimento: String,
  localizacao: String,
  role: "utilizador" | "admin"
}
```

**`eventos`**
```
{
  titulo, descricao, data, horaInicio, horaFim,
  local, categoria, materiais,
  maxParticipantes: int,
  inscritos: [uid, ...],
  autorId, autorNome,
  criadoEm: Timestamp
}
```

**`noticias`**
```
{
  titulo, descricao, resumo, fonte,
  imagemUrl, categoria,
  dataPublicacao: Timestamp,
  criadoPor: uid
}
```

**`notifications`**
```
{
  titulo, mensagem,
  data: Timestamp,
  noticiaId?: String,
  tipo?: String
}
```

---

## Serviços Internos

### `AuthService`
- `register()` — cria conta Firebase e guarda dados no Firestore
- `login()` — autenticação com email/password
- `updateUserProfile()` — atualiza nome, data de nascimento e localização
- `showEditProfileSheet()` — bottom sheet de edição de perfil

### `EventService`
- `criarEvento()` — adiciona evento ao Firestore com dados do autor
- `editarEvento()` — atualiza campos de um evento existente
- `apagarEvento()` — elimina evento (apenas pelo autor)
- `toggleInscricao()` — inscreve ou cancela inscrição do utilizador autenticado
- `getEventos()` — stream de todos os eventos ordenados por data de criação

### `AdminService`
- `isAdmin()` — verifica se o utilizador atual tem `role == 'admin'`
- `adminStream()` — stream reativo para mudanças de role

### `NotificationService`
- `addNotification()` — adiciona documento na coleção `notifications`

### `LocalNotificationService`
- Inicializa `flutter_local_notifications`
- `showNotification()` — exibe notificação push local ao receber novos documentos no Firestore

### `DirectionsRepository`
- `getDirections()` — chama Google Directions API e devolve modelo `Directions` com polyline, distância e duração

### `MarkersService`
- `buildMarkers()` — gera conjunto de `Marker` para o Google Maps a partir dos dados estáticos de pontos

---

## Requisitos e Instalação

### Pré-requisitos
- Flutter SDK `>=3.0.0`
- Dart `>=3.0.0`
- Conta Firebase com projeto configurado
- Chave de API Google Maps (Android + iOS) e Google Directions API

### Instalação

```bash
# 1. Clonar o repositório
git clone <url-do-repositório>
cd projeto_cm_25_26-main

# 2. Instalar dependências
flutter pub get

# 3. Correr a aplicação
flutter run
```

### Dependências principais (`pubspec.yaml`)

| Package | Utilização |
|---|---|
| `firebase_core` | Inicialização Firebase |
| `firebase_auth` | Autenticação |
| `cloud_firestore` | Base de dados |
| `google_maps_flutter` | Mapa interativo |
| `flutter_local_notifications` | Notificações push locais |
| `http` | Chamadas à Directions API |

---

## Configuração Firebase

1. Criar projeto em [console.firebase.google.com](https://console.firebase.google.com)
2. Adicionar app Android e/ou iOS ao projeto Firebase
3. Descarregar `google-services.json` (Android) e/ou `GoogleService-Info.plist` (iOS)
4. Colocar os ficheiros nas pastas respetivas (`android/app/` e `ios/Runner/`)
5. O ficheiro `lib/firebase_options.dart` é gerado automaticamente com `flutterfire configure`

---

## Configuração Google Maps

Adicionar a chave de API no ficheiro correspondente à plataforma:

**Android** — `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="SUA_CHAVE_AQUI"/>
```

**iOS** — `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("SUA_CHAVE_AQUI")
```

A chave da **Directions API** é gerida em `lib/services/.env.dart` (não deve ser incluída no controlo de versão).

---

## Permissões

### Android (`AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

### iOS (`Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necessário para mostrar a sua localização no mapa.</string>
```

---

## Papéis de Utilizador

| Role | Permissões |
|---|---|
| `utilizador` | Registo e login, ver mapa, criar e gerir os próprios eventos, inscrever-se em eventos, fazer doações, ler notícias e fórum |
| `admin` | Todas as permissões acima + publicar, editar e apagar notícias + acesso ao ícone de administração na AppBar |

O role `admin` é atribuído manualmente no Firestore (campo `role` no documento do utilizador na coleção `users`).

---

*Desenvolvido no âmbito da unidade curricular de Computação Móvel — 2025/2026*