*** Settings ***
Documentation   Documentação da API: https://fakerestapi.azurewebsites.net/swagger/ui/index#/Books
Library         RequestsLibrary
Library         Collections

*** Variables ***
${URL_API}   https://fakerestapi.azurewebsites.net/api/
&{BOOK_15}      ID=15
...             Title=Book 15
...             Description=Lorem lorem lorem. Lorem lorem lorem. Lorem lorem lorem.\r\n
...             PageCount=1500
...             Excerpt=Lorem lorem lorem. Lorem lorem lorem. Lorem lorem lorem.\r\nLorem lorem lorem. Lorem lorem lorem. Lorem lorem lorem.\r\nLorem lorem lorem. Lorem lorem lorem. Lorem lorem lorem.\r\nLorem lorem lorem. Lorem lorem lorem. Lorem lorem lorem.\r\nLorem lorem lorem. Lorem lorem lorem. Lorem lorem lorem.\r\n

&{BOOK_2323}    ID=2323
...             Title=teste
...             Description=string
...             PageCount=0
...             Excerpt=string

&{BOOK_150}     ID=0
...             Title=string
...             Description=Alterado
...             PageCount=0
...             Excerpt=string

*** Keywords ***
# Setup e Teardown
Conectar a minha API
  Create Session     fakeAPI    ${URL_API}

# Ações
Requisitar todos os livros
  ${RESPOSTA}    Get Request    fakeAPI    Books
  Log                        ${RESPOSTA.text}
  # Tornar Variavel Global
  Set Test Variable    ${RESPOSTA}

Requisitar o livro "${ID_LIVRO}"
  ${RESPOSTA}    Get Request    fakeAPI    Books/${ID_LIVRO}
  Log                        ${RESPOSTA.text}
  # Tornar Variavel Global
  Set Test Variable    ${RESPOSTA}

Cadastrar um novo livro
  ${HEADERS}     Create Dictionary    content-type=application/json
  ${RESPOSTA}    Post Request    fakeAPI    Books/
  ...                            data={"ID":2323,"Title":"teste","Description": "string","PageCount": 0,"Excerpt":"string","PublishDate":"2020-07-30T17:09:26.899Z"}
  ...                            headers=${HEADERS}
  Log                  ${RESPOSTA.text}
  # Tornar Variavel Global
  Set Test Variable    ${RESPOSTA}

Alterar dados do livro "${ID_LIVRO}"
  ${HEADERS}     Create Dictionary    content-type=application/json
  ${RESPOSTA}    Put Request          fakeAPI         Books/${ID_LIVRO}
  ...                                 data={"ID": 0,"Title": "string","Description": "Alterado","PageCount": 0,"Excerpt": "string","PublishDate": "2020-07-30T17:09:26.900Z"}
  ...                                 headers=${HEADERS}
  Log            ${RESPOSTA.text}
  # Tornar Variavel Global
  Set Test Variable    ${RESPOSTA}

Deletar o livro "${ID_LIVRO}"
  ${HEADERS}     Create Dictionary    content-type=application/json
  ${RESPOSTA}    Delete Request       fakeAPI         Books/${ID_LIVRO}
  ...                                 headers=${HEADERS}
  Log            ${RESPOSTA.text}
  # Tornar Variavel Global
  Set Test Variable    ${RESPOSTA}

# Conferências
Conferir o status code
  [Arguments]    ${STATUSCODE_DESEJADO}
  Should Be Equal As Strings    ${RESPOSTA.status_code}    ${STATUSCODE_DESEJADO}

Conferir o reason
  [Arguments]    ${REASON_DESEJADO}
  Should Be Equal As Strings    ${RESPOSTA.reason}    ${REASON_DESEJADO}

Conferir se retorna uma lista com "${QTDE_LIVROS}" livros
  Length Should Be    ${RESPOSTA.json()}    ${QTDE_LIVROS}

Conferir se retorna todos os dados corretos do livro 15
  Dictionary Should Contain Item    ${RESPOSTA.json()}    ID             ${BOOK_15.ID}
  Dictionary Should Contain Item    ${RESPOSTA.json()}    Title          ${BOOK_15.Title}
  Dictionary Should Contain Item    ${RESPOSTA.json()}    Description    ${BOOK_15.Description}
  Dictionary Should Contain Item    ${RESPOSTA.json()}    PageCount      ${BOOK_15.PageCount}
  Dictionary Should Contain Item    ${RESPOSTA.json()}    Excerpt        ${BOOK_15.Excerpt}
  Should Not Be Empty               ${RESPOSTA.json()["PublishDate"]}

Conferir se retorna todos os dados cadastrados do livro "${ID_LIVRO}"
  Conferir livro       ${ID_LIVRO}

Conferir se retorna todos os dados alterados do livro "${ID_LIVRO}"
  Conferir livro       ${ID_LIVRO}

Conferir livro
  [Arguments]          ${ID_LIVRO}
  Dictionary Should Contain Item    ${RESPOSTA.json()}    ID             ${BOOK_${ID_LIVRO}.ID}
  Dictionary Should Contain Item    ${RESPOSTA.json()}    Title          ${BOOK_${ID_LIVRO}.Title}
  Dictionary Should Contain Item    ${RESPOSTA.json()}    Description    ${BOOK_${ID_LIVRO}.Description}
  Dictionary Should Contain Item    ${RESPOSTA.json()}    PageCount      ${BOOK_${ID_LIVRO}.PageCount}
  Dictionary Should Contain Item    ${RESPOSTA.json()}    Excerpt        ${BOOK_${ID_LIVRO}.Excerpt}
  Should Not Be Empty               ${RESPOSTA.json()["PublishDate"]}

Conferir se deleta o livro "${ID_LIVRO}" (a response body deve ser vazio)
  Should Be Empty         ${RESPOSTA.content}
