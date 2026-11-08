# Deltascord

Projeto inicial Flutter para Android.

## Estado atual

Esta versão contém somente:
- Tela inicial de cadastro/login por nickname e senha.
- Tema escuro roxo.
- Tela inicial com atalhos demonstrativos.
- Esquema SQL inicial para perfis e limite de cinco contas.
- Workflow do GitHub Actions para gerar um APK Android.

**Ainda não implementado:** amigos, mensagens, salas de voz, compartilhamento de tela e soundboard. O login com e-mail sintético também precisa ser testado no projeto Supabase antes de considerar o cadastro funcional.

## Supabase

1. Abra o SQL Editor do projeto Supabase.
2. Execute `supabase/schema.sql`.
3. Em Authentication > Providers > Email, mantenha o provedor habilitado e desative a confirmação de e-mail, conforme a configuração de teste.
4. No GitHub, abra Settings > Secrets and variables > Actions e crie:
   - `SUPABASE_URL`: URL do projeto.
   - `SUPABASE_ANON_KEY`: chave publishable/anon do projeto.

Nunca coloque a chave `service_role` ou qualquer chave secreta no aplicativo ou no repositório.

## Gerar APK

O workflow em `.github/workflows/android-build.yml` roda ao enviar commits para `main` ou manualmente em Actions. O APK aparece como artifact da execução.

Este é um ponto de partida, não um aplicativo pronto para uso.
