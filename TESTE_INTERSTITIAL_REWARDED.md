# 🧪 Guia de Teste - Interstitial e Rewarded Ads

## ✅ **Melhorias Implementadas**

### **1. Debug Logs Detalhados:**
- ✅ **Carregamento**: Logs para cada tipo de ad
- ✅ **Status**: Verificação de condições em tempo real
- ✅ **Erros**: Mensagens específicas para cada problema

### **2. Seção Debug (Apenas em DEBUG):**
- ✅ **Status dos Ads**: Visualização em tempo real
- ✅ **Botões de Teste**: Forçar exibição de ads
- ✅ **Recarregar Ads**: Forçar carregamento
- ✅ **Reset Frequência**: Limpar contadores

## 🔍 **Como Testar Agora**

### **1. Execute o App e Abra Configurações**
```bash
# Execute no simulador e vá para Settings
```

### **2. Verifique a Nova Seção Debug**
Na parte inferior das configurações, você verá:

```
🐛 Debug - Ads
├── 📊 Status dos Ads
├── 🔄 Recarregar Todos os Ads
├── 🎯 Testar Interstitial
├── 🎁 Testar Rewarded
└── 🔄 Reset Frequência
```

### **3. Teste Passo a Passo**

#### **Passo 1: Verificar Status**
- Toque em **"📊 Status dos Ads"**
- Deve mostrar:
  ```
  📊 Status dos Ads:
  • Banner: ✅ Carregado
  • Interstitial: ✅/❌ Carregado
  • Rewarded: ✅/❌ Carregado
  • Cálculos: 0/3
  ```

#### **Passo 2: Recarregar Ads (se necessário)**
- Se algum ad mostrar ❌, toque em **"🔄 Recarregar Todos os Ads"**
- Aguarde alguns segundos e verifique o status novamente

#### **Passo 3: Testar Rewarded Ad**
- Toque em **"🎁 Testar Rewarded"**
- **Resultado esperado**: Ad de teste do Google aparece
- **Se não funcionar**: Verifique logs no console

#### **Passo 4: Testar Interstitial Ad**
- Toque em **"🎯 Testar Interstitial"**
- **Resultado esperado**: Ad em tela cheia aparece
- **Se não funcionar**: Verifique logs no console

## 📱 **Logs no Console do Xcode**

Abra o **Console** (Cmd+Shift+C) e procure por:

### **Carregamento Bem-Sucedido:**
```
🔄 Carregando interstitial ad com ID: ca-app-pub-3940256099942544/4411468910
✅ Interstitial ad carregado com sucesso

🔄 Carregando rewarded ad com ID: ca-app-pub-3940256099942544/1712485313
✅ Rewarded ad carregado com sucesso
```

### **Teste de Rewarded Ad:**
```
🎯 Tentando mostrar rewarded ad...
📊 Status: rewardedAdLoaded = true
✅ Apresentando rewarded ad...
🎉 Usuário ganhou a recompensa!
```

### **Teste de Interstitial Ad:**
```
🔧 Forçando exibição de interstitial...
✅ Apresentando interstitial ad...
```

## 🐛 **Troubleshooting**

### **Problema 1: "❌ Interstitial não está carregado"**
```
Causa: Ad não foi carregado ainda
Solução: 
1. Toque em "🔄 Recarregar Todos os Ads"
2. Aguarde 5-10 segundos
3. Tente novamente
```

### **Problema 2: "❌ Rewarded ad não está carregado"**
```
Causa: Ad não foi carregado ainda
Solução:
1. Verifique conexão com internet
2. Toque em "🔄 Recarregar Todos os Ads"
3. Aguarde e tente novamente
```

### **Problema 3: "❌ Root view controller não encontrado"**
```
Causa: Problema de contexto da view
Solução:
1. Feche e reabra as configurações
2. Reinicie o app
3. Teste novamente
```

### **Problema 4: Ads não carregam nunca**
```
Possíveis causas:
• Simulador sem internet
• IDs de teste incorretos
• Problema com Google AdMob SDK

Verificações:
1. Confirme conexão com internet
2. Verifique logs de erro no console
3. Teste em dispositivo real
```

## 🎯 **Teste do Interstitial Automático**

### **Como Funciona:**
- Interstitial aparece **após 3 cálculos** de poker
- Cooldown de **5 minutos** entre interstitials

### **Para Testar:**
1. **Faça 3 cálculos** de poker (selecione cartas e calcule)
2. **No 3º cálculo**, interstitial deve aparecer automaticamente
3. **Verifique logs**:
   ```
   📊 Cálculo completado! Total: 3
   🔍 Verificando condições para interstitial:
      📊 Cálculos: 3/3
      ✅ Primeiro interstitial
      📱 Ad carregado: true
   ✅ Condições atendidas, mostrando interstitial...
   ```

### **Para Resetar Teste:**
- Toque em **"🔄 Reset Frequência"** nas configurações
- Isso zera o contador de cálculos

## 🚀 **Próximos Passos**

### **Se os Ads Funcionarem:**
1. ✅ **Remover seção debug** antes de publicar
2. ✅ **Configurar IDs de produção**
3. ✅ **Testar em dispositivo real**
4. ✅ **Publicar na App Store**

### **Se Houver Problemas:**
1. 🔧 **Copie os logs do console**
2. 🔧 **Informe qual botão não funciona**
3. 🔧 **Teste em dispositivo real**
4. 🔧 **Reporte o erro específico**

---

## 📞 **Como Reportar Problemas**

Se algum ad não funcionar:

1. **Execute o app**
2. **Vá para Settings → Debug**
3. **Copie o "📊 Status dos Ads"**
4. **Tente o botão que não funciona**
5. **Copie os logs do console**
6. **Informe qual erro apareceu**

**Exemplo de report:**
```
Status: Interstitial ❌, Rewarded ✅
Botão testado: 🎯 Testar Interstitial
Erro no console: "❌ Interstitial não está carregado"
```

Agora você tem **controle total** para testar e debugar todos os tipos de ads! 🎉
