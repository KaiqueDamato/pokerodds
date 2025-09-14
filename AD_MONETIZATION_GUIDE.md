# 📱 Guia de Monetização - Poker Odds App

## 🎯 Estratégia de Monetização Implementada

Este app implementa uma estratégia de monetização **não-intrusiva** que preserva a experiência do usuário enquanto gera receita passiva através de anúncios estrategicamente posicionados.

## 🚀 Tipos de Anúncios Implementados

### 1. **Banner Ads** (Prioridade Alta)
- **Localização**: Parte inferior da tela
- **Comportamento**: Ocultos durante simulações
- **Impacto**: Mínimo na UX
- **Receita**: Constante e previsível

### 2. **Interstitial Ads** (Prioridade Média)
- **Trigger**: Após 3 cálculos bem-sucedidos
- **Cooldown**: 5 minutos entre exibições
- **Timing**: Apenas entre sessões
- **Receita**: Alta por impressão

### 3. **Rewarded Ads** (Prioridade Alta)
- **Benefício**: Modo alta precisão (200k iterações)
- **Benefício**: Análise detalhada por street (futuro)
- **Valor**: Usuário escolhe assistir
- **Receita**: Excelente eCPM

## 📋 Configuração Necessária

### Passo 1: Configurar Google AdMob
1. Acesse [Google AdMob Console](https://admob.google.com/)
2. Crie uma nova conta/app se necessário
3. Obtenha seus Ad Unit IDs

### Passo 2: Substituir IDs de Teste
Edite o arquivo `AdConfiguration.swift`:

```swift
// Substitua pelos seus IDs reais
static let productionBannerAdUnitID = "ca-app-pub-8913194362956705/3008362472" // ✅ Já configurado
static let productionInterstitialAdUnitID = "ca-app-pub-SEU_ID/INTERSTITIAL_ID"
static let productionRewardedAdUnitID = "ca-app-pub-SEU_ID/REWARDED_ID"
```

### Passo 3: Verificar SKAdNetwork (✅ Já Configurado)
O arquivo `Info.plist` já contém todos os 79 identificadores SKAdNetwork necessários para:
- **Google AdMob** (principal): `cstr6suwn9.skadnetwork`
- **Pubmatic**: `kbmxgpxpgc.skadnetwork`
- **StackAdapt**: `424m5254lk.skadnetwork`
- **Verve**: `w9q455wk68.skadnetwork`
- **Viant**: `9b89h5y424.skadnetwork`
- **Zemanta**: `feyaarzu9v.skadnetwork`
- **74 outras redes** de mediação compatíveis
- Rastreamento de conversões iOS 14.5+

### Passo 4: Ativar Modo Produção
```swift
static var isTestMode: Bool {
    #if DEBUG
    return true
    #else
    return false // ✅ Já configurado para produção
    #endif
}
```

## 💰 Projeção de Receita

### Estimativas Conservadoras (baseadas em benchmarks da indústria):

**Usuários Ativos Diários: 1.000**
- Banner Ads: $2-5 CPM → $60-150/mês
- Interstitial Ads: $8-15 CPM → $120-300/mês  
- Rewarded Ads: $15-30 CPM → $200-500/mês

**Total Estimado: $380-950/mês**

### Fatores que Influenciam a Receita:
- Geografia dos usuários (US/EU = maior CPM)
- Engagement e retenção
- Qualidade do tráfego
- Sazonalidade

## 🎨 Preservação da UX

### ✅ Boas Práticas Implementadas:
- Banner oculto durante simulações
- Interstitials apenas entre sessões
- Rewarded ads são opcionais
- Cooldowns respeitosos
- Feedback háptico para premium features

### ❌ Evitamos:
- Ads durante cálculos ativos
- Pop-ups intrusivos
- Frequência excessiva
- Interrupção do fluxo principal

## 📊 Métricas Importantes

### KPIs para Monitorar:
1. **Fill Rate**: % de requests atendidos
2. **eCPM**: Receita por 1000 impressões
3. **CTR**: Taxa de cliques (banner/interstitial)
4. **Completion Rate**: % de rewarded ads completos
5. **Retention**: Impacto dos ads na retenção

### Ferramentas de Analytics:
- Google AdMob Dashboard
- Firebase Analytics (recomendado)
- Adjust/AppsFlyer (opcional)

## 🔧 Configurações Avançadas

### Otimização de Performance:
```swift
// AdConfiguration.swift - Ajuste conforme necessário
static let calculationsBeforeInterstitial = 3 // Aumente se muito intrusivo
static let interstitialCooldownSeconds: TimeInterval = 300 // 5 min padrão
static let premiumFeatureDuration: TimeInterval = 1800 // 30 min premium
```

### Segmentação de Usuários:
- Usuários novos: Mais conservador com ads
- Usuários engajados: Podem ver mais interstitials
- Power users: Focar em rewarded ads

## 🚀 Próximos Passos

### Fase 1 - Lançamento (Atual):
- [x] Banner ads básicos
- [x] Interstitials estratégicos  
- [x] Rewarded para alta precisão
- [ ] Testes A/B de posicionamento

### Fase 2 - Otimização:
- [ ] Mediation com múltiplas redes
- [ ] Segmentação de usuários
- [ ] Native ads na tela de configurações
- [ ] Analytics avançados

### Fase 3 - Expansão:
- [ ] Subscription premium (remove ads)
- [ ] Features premium adicionais
- [ ] Offerwall integration
- [ ] Cross-promotion com outros apps

## 📁 Arquivos Implementados

### Sistema de Ads:
- `pokerodds/Ads/AdConfiguration.swift` - Configurações centrais
- `pokerodds/Ads/AdManager.swift` - Gerenciador principal
- `pokerodds/Ads/BannerAdView.swift` - Banner ads responsivos
- `pokerodds/Ads/RewardedAdButton.swift` - Botões premium

### Integrações:
- `pokerodds/App/PokerOddsApp.swift` - Inicialização do AdMob
- `pokerodds/Views/ContentView.swift` - Banner na interface
- `pokerodds/Views/SettingsSheet.swift` - Features premium
- `pokerodds/ViewModels/OddsViewModel.swift` - Hooks de controle

## 🔧 Teste e Validação

### Para Testar:
1. Execute o app em modo Debug (usa IDs de teste)
2. Verifique se os banners aparecem na parte inferior
3. Teste as features premium na tela de configurações
4. Faça 3+ cálculos para ver interstitials

### Para Produção:
1. Configure seus IDs reais no `AdConfiguration.swift`
2. Teste em modo Release
3. Monitore métricas no AdMob Dashboard

## 📞 Suporte

Para dúvidas sobre implementação ou otimização:
- Documentação AdMob: [developers.google.com/admob](https://developers.google.com/admob)
- Comunidade iOS: Stack Overflow, Reddit r/iOSProgramming
- Consultoria especializada: Considere contratar especialista em monetização mobile

---

**💡 Dica Final**: Comece conservador e aumente gradualmente a frequência dos ads baseado no feedback dos usuários e métricas de retenção. A experiência do usuário sempre deve vir primeiro!
