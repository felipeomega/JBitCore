#!/bin/bash
# Este script cria ou remove um usuário no Linux
#Criado por Felipe Omega
#jbitcore.tec.br

# Verifica se o script está sendo executado como root
if [ $(id -u) -ne 0 ]; then
  echo "Este script deve ser executado como root."
  exit 1
fi

# Solicita se deseja adicionar ou remover um usuário
read -p "Deseja adicionar ou remover um usuário? (adicionar/remover) " ACTION

if [ "$ACTION" == "adicionar" ]; then
  # Solicita o nome do novo usuário
  read -p "Digite o nome do novo usuário: " USERNAME

  # Solicita uma senha para o novo usuário
  read -s -p "Digite a senha para o novo usuário: " PASSWORD
  echo

  # Lista todos os grupos do sistema
  echo "Grupos disponíveis:"
  getent group | cut -d: -f1

  # Solicita quais grupos o novo usuário deve ser adicionado
  read -p "Digite o nome dos grupos que o usuário deve ser adicionado (separados por vírgula): " GROUPS

  # Cria a conta de usuário
  sudo useradd -m $USERNAME

  # Define a senha para o novo usuário
  echo "$USERNAME:$PASSWORD" | sudo chpasswd

  # Define o shell padrão para o novo usuário
  sudo usermod -s /bin/bash $USERNAME

  # Adiciona o novo usuário aos grupos especificados
  IFS=',' read -ra GROUPS_ARRAY <<< "$GROUPS"
  for GROUP in "${GROUPS_ARRAY[@]}"; do
    sudo usermod -aG $GROUP $USERNAME
  done

 # Verifica se o usuário deve ser adicionado ao grupo sudoers
  read -p "Deseja adicionar o usuário ao grupo sudoers? (s/n) " ADD_TO_SUDOERS
  if [ "$ADD_TO_SUDOERS" == "s" ]; then
    sudo usermod -aG sudo $USERNAME
    echo "Usuário $USERNAME adicionado ao grupo sudoers."
  else
    echo "Usuário $USERNAME criado sem acesso ao sudo."
  fi

  echo "Usuário $USERNAME criado com sucesso!"

elif [ "$ACTION" == "remover" ]; then
  # Lista todos os usuários do sistema
  echo "Usuários disponíveis:"
  awk -F':' '{ print $1}' /etc/passwd

  # Solicita o nome do usuário que deve ser removido
  read -p "Digite o nome do usuário que deseja remover: " USERNAME

  # Remove a conta de usuário
  sudo userdel -r $USERNAME

  echo "Usuário $USERNAME removido com sucesso!"
else
  echo "Opção inválida. Tente novamente."
  exit 1
fi
