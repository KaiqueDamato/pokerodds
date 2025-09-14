# 🧪 Guia de Teste para Banner Ads

## ✅ **Configuração Atual**

### **IDs de Teste Configurados:**
- **Banner Test ID**: `ca-app-pub-3940256099942544/2934735716` ✅
- **Modo Debug**: Ativo (automaticamente em DEBUG builds)
- **SKAdNetwork**: 79 identificadores configurados ✅

## 🔍 **Como Testar Banner Ads**

### **1. Execute o App no Simulador**
```bash
# No Xcode, pressione Cmd+R ou use:
xcodebuild -scheme pokerodds -destination 'platform=iOS Simulator,name=iPhone 16' build
```

### **2. O que Você Deve Ver**

#### **Cenário A: Banner Carregado com Sucesso**
- ✅ Banner aparece na **parte inferior da tela**
- ✅ Tamanho: **320x50 pixels**
- ✅ Conteúdo: **"Test Ad" do Google AdMob**
- ✅ Cor de fundo clara com borda sutil

#### **Cenário B: Banner Não Carregado (Debug Mode)**
- 🔄 Placeholder aparece com texto **"🔄 Carregando anúncio..."**
- 🔧 Botão **"Tentar novamente"** disponível
- 📱 Área reservada de **320x50 pixels** com borda azul

### **3. Logs de Debug no Console**

Abra o **Console do Xcode** (Cmd+Shift+C) e procure por:

```
🎯 Criando BannerView...
✅ Root view controller configurado
🔄 Carregando banner ad...
Banner ad carregado com sucesso
```

**OU** (se houver erro):
```
❌ Banner ad não foi criado ainda
⚠️ Root view controller não encontrado
Erro ao carregar banner: [descrição do erro]
```

### **4. Comportamento Durante Simulação**

- **Antes da simulação**: Banner visível ✅
- **Durante simulação**: Banner oculto 🚫
- **Após simulação**: Banner volta a aparecer ✅

## 🐛 **Troubleshooting**

### **Se o Banner NÃO Aparecer:**

#### **Problema 1: Placeholder Permanente**
```
Sintoma: Só aparece "🔄 Carregando anúncio..."
Solução: Toque em "Tentar novamente" várias vezes
```

#### **Problema 2: Nada Aparece**
```
Sintoma: Nenhum banner ou placeholder
Causa: showBannerAd = false
Solução: Reinicie o app
```

#### **Problema 3: Erro de Rede**
```
Sintoma: "Failed to load ad"
Causa: Simulador sem internet ou ID inválido
Solução: Verifique conexão e IDs de teste
```

### **Comandos de Debug:**

#### **1. Verificar Logs Completos**
```bash
# Execute e observe o console do Xcode
xcrun simctl spawn booted log stream --predicate 'process == "pokerodds"'
```

#### **2. Forçar Recarga do Banner**
- Toque no botão **"Tentar novamente"** no placeholder
- Ou reinicie o app completamente

#### **3. Verificar Configuração**
```bash
# Confirmar ID de teste
grep -n "testBannerAdUnitID" /Users/kaiquedamato/Developer/pokerodds/pokerodds/Ads/AdConfiguration.swift
```

## 📱 **Teste em Dispositivo Real**

### **Para Testar em iPhone/iPad:**

1. **Conecte o dispositivo**
2. **Selecione o dispositivo no Xcode**
3. **Execute o app (Cmd+R)**
4. **Resultado esperado**: Banner com anúncios reais do Google

### **Diferenças Dispositivo vs Simulador:**
- **Simulador**: Ads de teste do Google
- **Dispositivo**: Pode mostrar ads reais (mesmo em DEBUG)
- **Performance**: Melhor em dispositivo real

## 🎯 **Próximos Passos**

### **Se os Banners Funcionarem:**
1. ✅ Teste interstitial ads (após 3 cálculos)
2. ✅ Teste rewarded ads (nas configurações)
3. ✅ Configure IDs de produção
4. ✅ Publique na App Store

### **Se Houver Problemas:**
1. 🔧 Verifique logs no console
2. 🔧 Teste em dispositivo real
3. 🔧 Confirme conexão com internet
4. 🔧 Reporte o erro específico

---

## 📞 **Suporte**

Se o banner ainda não aparecer após seguir este guia:

1. **Copie os logs do console**
2. **Tire screenshot da tela**
3. **Informe qual cenário está acontecendo**
4. **Mencione se está no simulador ou dispositivo**

**Lembre-se**: Ads de teste podem levar alguns segundos para carregar no simulador! 🕐
