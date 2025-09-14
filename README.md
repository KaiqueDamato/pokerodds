# PokerOdds

Uma calculadora elegante e acessível de probabilidade de vitória em Texas Hold'em para iOS, desenvolvida em SwiftUI.

## Sobre o App

PokerOdds permite calcular suas chances de vitória em uma mesa heads-up (1 contra 1) de Texas Hold'em. Você seleciona suas 2 cartas e, opcionalmente, as cartas comunitárias conhecidas (flop/turn/river), e o app calcula as probabilidades de vitória, empate e derrota através de simulação Monte Carlo.

### Características Principais

- ✨ **Interface Elegante**: Design moderno seguindo as Apple Human Interface Guidelines
- 🌓 **Suporte Total a Dark Mode**: Interface adaptável para temas claro e escuro
- ♿ **Acessibilidade Completa**: Suporte a VoiceOver, Dynamic Type e Reduce Motion
- 🎯 **Simulação Precisa**: Engine Monte Carlo com 5.000 a 100.000 iterações
- 🇧🇷 **Localização**: Suporte completo para português brasileiro e inglês
- 📱 **iOS 16+**: Aproveitando as mais recentes funcionalidades do sistema

## Como Funciona

### Simulação Monte Carlo

O app utiliza simulação Monte Carlo para estimar probabilidades. Para cada iteração:

1. **Distribui cartas aleatórias** para o oponente (2 cartas)
2. **Completa o board** com cartas aleatórias restantes (se necessário)
3. **Avalia ambas as mãos** usando algoritmos de ranking de poker
4. **Registra o resultado** (vitória, empate ou derrota)

Após milhares de iterações, obtém-se uma estimativa estatística confiável das probabilidades reais.

### Precisão vs Velocidade

- **Modo Rápido**: 8.000 iterações (~1-2 segundos)
- **Modo Padrão**: 20.000 iterações (~3-5 segundos)
- **Modo Preciso**: Até 100.000 iterações (~10-15 segundos)

Mais iterações = maior precisão, mas maior tempo de execução.

## Interface do Usuário

### Tela Principal
- **Sua Mão**: Selecione suas 2 cartas hole
- **Mesa**: Selecione as cartas comunitárias conhecidas (opcional)
- **Botão Calcular**: Inicia a simulação
- **Resultados**: Mostra percentuais de vitória/empate/derrota

### Seletor de Cartas
- Grade 13×4 organizando todas as 52 cartas
- Cartas já utilizadas ficam desabilitadas
- Interface otimizada para toque e acessibilidade

### Configurações
- **Modo Rápido**: Toggle para simulações mais rápidas
- **Iterações**: Slider para ajustar precisão (5.000-100.000)
- **Redefinir**: Limpa todas as cartas selecionadas

## Arquitetura Técnica

### MVVM (Model-View-ViewModel)
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│     Models      │    │   ViewModels     │    │     Views       │
├─────────────────┤    ├──────────────────┤    ├─────────────────┤
│ • Card          │◄───┤ • OddsViewModel  │◄───┤ • ContentView   │
│ • Deck          │    │                  │    │ • CardSlotView  │
│ • HandRank      │    │                  │    │ • CardPicker    │
│ • HandEvaluator │    │                  │    │ • SettingsSheet │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         ▲                       ▲
         │                       │
┌─────────────────┐    ┌──────────────────┐
│   Simulation    │    │   Resources      │
├─────────────────┤    ├──────────────────┤
│ • MonteCarloEngine│    │ • Assets         │
│ • CancellationToken│   │ • Localizable   │
└─────────────────┘    └──────────────────┘
```

### Modelos Principais

- **`Card`**: Representa uma carta com naipe e rank
- **`Deck`**: Gerencia o baralho de 52 cartas
- **`HandEvaluator`**: Avalia mãos de poker (5-7 cartas)
- **`MonteCarloEngine`**: Executa simulações assíncronas

### Avaliação de Mãos

O `HandEvaluator` identifica e compara mãos de poker:
- Royal Flush > Straight Flush > Four of a Kind > Full House > Flush > Straight > Three of a Kind > Two Pair > Pair > High Card
- Suporta tanto Ás alto (A-K-Q-J-10) quanto Ás baixo (A-2-3-4-5) em straights
- Resolve empates através de kickers detalhados

## Requisitos

- iOS 16.0+
- iPhone/iPad
- Xcode 15.0+
- Swift 5.9+

## Instalação

1. Clone o repositório:
```bash
git clone https://github.com/usuario/pokerodds.git
cd pokerodds
```

2. Abra o projeto no Xcode:
```bash
open PokerOdds.xcodeproj
```

3. Compile e execute no simulador ou dispositivo

## Estrutura do Projeto

```
PokerOdds/
├── App/
│   └── PokerOddsApp.swift           # Entry point da aplicação
├── Models/
│   ├── Card.swift                   # Estruturas de carta, naipe e rank
│   ├── Deck.swift                   # Gerenciador do baralho
│   ├── HandRank.swift               # Rankings e comparação de mãos
│   └── HandEvaluator.swift          # Avaliador de mãos de poker
├── Simulation/
│   └── MonteCarloEngine.swift       # Engine de simulação assíncrona
├── ViewModels/
│   └── OddsViewModel.swift          # ViewModel principal (MVVM)
├── Views/
│   ├── ContentView.swift            # Tela principal
│   ├── CardSlotView.swift           # Slot individual de carta
│   ├── CardPickerView.swift         # Seletor de cartas em grade
│   ├── SettingsSheet.swift          # Painel de configurações
│   ├── EmptyStateView.swift         # Estado vazio
│   ├── ErrorStateView.swift         # Estado de erro
│   └── ResultCardView.swift         # Card de resultados
├── Resources/
│   ├── Assets.xcassets/             # Cores, ícones e assets visuais
│   └── Localizable.strings          # Strings localizadas
└── Tests/
    ├── HandEvaluatorTests.swift     # Testes do avaliador de mãos
    └── MonteCarloEngineTests.swift  # Testes da simulação
```

## Testes

O projeto inclui testes unitários abrangentes:

### HandEvaluatorTests
- ✅ Detecção correta de todos os rankings
- ✅ Comparação e desempate por kickers
- ✅ Suporte a straights com Ás baixo/alto
- ✅ Mãos de 5 e 7 cartas
- ✅ Testes de performance

### MonteCarloEngineTests
- ✅ Simulações básicas e estatísticas
- ✅ Validação de configuração
- ✅ Cancelamento e callbacks de progresso
- ✅ Consistência estatística
- ✅ Casos extremos (nuts, boards parciais)

Execute os testes:
```bash
# Via Xcode: Cmd+U
# Via linha de comando:
xcodebuild test -scheme PokerOdds -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

## Configuração e Personalização

### Alterando Iterações Padrão
Edite `OddsViewModel.swift`:
```swift
@Published var iterationsCount: Int = 20000  // Altere aqui
```

### Modo Rápido
Edite `OddsViewModel.swift`:
```swift
var fastMode: Bool = false {
    didSet {
        iterationsCount = fastMode ? 8000 : 20000  // Altere 8000 aqui
    }
}
```

### Adicionando Idiomas
1. Adicione `.strings` file em `Resources/`
2. Configure o projeto para suportar novos idiomas
3. Traduza todas as chaves em `Localizable.strings`

## Limitações Atuais (MVP)

- ❌ **Apenas heads-up**: Limitado a 1 oponente (pode ser expandido)
- ❌ **Sem ranges**: Não considera ranges específicos do oponente
- ❌ **Sem histórico**: Não salva simulações anteriores
- ❌ **Sem análise de equity**: Apenas win/tie/loss percentuais

## Roadmap Futuro

### Versão 1.1
- [ ] Suporte para múltiplos oponentes (3-10 jogadores)
- [ ] Histórico de simulações
- [ ] Análise de equity detalhada
- [ ] Exportação de resultados

### Versão 1.2
- [ ] Ranges de mãos do oponente
- [ ] Calculadora de pot odds
- [ ] Análise de posição
- [ ] Modo training/educativo

### Versão 2.0
- [ ] Suporte a outras variantes (Omaha, Stud)
- [ ] Análise GTO básica
- [ ] Integração com databases de mãos
- [ ] Modo multiplayer/social

## Performance

### Benchmarks Típicos (iPhone 15 Pro)
- **5.000 iterações**: ~0.5-1.0 segundos
- **20.000 iterações**: ~2.0-3.0 segundos  
- **100.000 iterações**: ~10-15 segundos

### Otimizações Implementadas
- ✅ Processamento assíncrono em background
- ✅ Processamento em lotes para progress updates
- ✅ Algoritmos otimizados de avaliação de mãos
- ✅ Reutilização de estruturas quando possível

## Contribuição

Contribuições são bem-vindas! Por favor:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### Guidelines
- Siga as convenções de código Swift
- Adicione testes para novas funcionalidades
- Mantenha a compatibilidade com iOS 16+
- Documente mudanças no README

## Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## Reconhecimentos

- Algoritmos de avaliação de mãos baseados em técnicas padrão da indústria
- Interface inspirada nas Apple Human Interface Guidelines
- Simulação Monte Carlo seguindo práticas estabelecidas de teoria dos jogos

---

**PokerOdds** - Desenvolvido com ♠️ para a comunidade de poker
