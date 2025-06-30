import requests
import base64
import json
import time
import random
import os

def criar_url_api(page_number=1, page_size=20):
    params = {
        "language": "pt-br",
        "pageNumber": page_number,
        "pageSize": page_size,
        "index": "IBOV",
        "segment": "1"
    }
    
    params_json = json.dumps(params, separators=(',', ':'))
    params_base64 = base64.b64encode(params_json.encode('utf-8')).decode('utf-8')
    url = f"https://sistemaswebb3-listados.b3.com.br/indexProxy/indexCall/GetPortfolioDay/{params_base64}"
    
    return url

def acessar_api_b3(page_number=1):
    url = criar_url_api(page_number)
    headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'}
    
    response = requests.get(url, headers=headers)
    
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Erro página {page_number}: {response.status_code}")
        return None

def extrair_data_arquivo(json_data):
    """Extrai a data do header e formata para nome de arquivo"""
    try:
        date_str = json_data['header']['date']  # "30/06/25"
        # Converter para formato mais legível: 30-06-25
        date_formatted = date_str.replace('/', '-')
        return date_formatted
    except:
        # Se der erro, usar data atual
        from datetime import datetime
        return datetime.now().strftime('%d-%m-%y')

def coletar_pagina_com_retry(page_number, max_tentativas=10):
    """Tenta coletar uma página até conseguir, com limite de tentativas"""
    tentativa = 1
    
    while tentativa <= max_tentativas:
        print(f"📥 Coletando página {page_number} (tentativa {tentativa})...")
        
        data = acessar_api_b3(page_number=page_number)
        
        if data:
            print(f"✅ Página {page_number} coletada com sucesso!")
            return data
        else:
            print(f"❌ Tentativa {tentativa} falhou para página {page_number}")
            
            if tentativa < max_tentativas:
                # Pausa progressiva: 2s, 4s, 6s...
                pausa = tentativa * 2
                print(f"⏳ Aguardando {pausa} segundos antes da próxima tentativa...")
                time.sleep(pausa)
                tentativa += 1
            else:
                print(f"🚨 ERRO: Página {page_number} falhou após {max_tentativas} tentativas!")
                return None
    
    return None

def scrape_ibovespa():
    """Faz scraping e retorna todos os JSONs - GARANTE completude"""
    print("🚀 Iniciando scraping do IBovespa...")
    
    # Primeira página
    primeira_pagina = acessar_api_b3(page_number=1)
    if not primeira_pagina:
        print("❌ ERRO CRÍTICO: Não foi possível acessar a primeira página!")
        return []
    
    # Extrair data para nome do arquivo
    data_portfolio = extrair_data_arquivo(primeira_pagina)
    print(f"📅 Data do portfólio: {data_portfolio}")
    
    total_pages = primeira_pagina['page']['totalPages']
    print(f"📄 Total de páginas necessárias: {total_pages}")
    
    todos_jsons = [primeira_pagina]  # Lista com todos os JSONs
    
    # Coletar páginas restantes com retry persistente
    for page in range(2, total_pages + 1):
        # Pausa aleatória inicial
        pausa = random.uniform(1, 2)
        print(f"⏳ Aguardando {pausa:.1f} segundos...")
        time.sleep(pausa)
        
        # Tentar coletar página até conseguir
        data = coletar_pagina_com_retry(page)
        
        if data:
            todos_jsons.append(data)
        else:
            print(f"🚨 FALHA CRÍTICA: Página {page} não pôde ser coletada!")
            print(f"💀 Scraping INCOMPLETO - faltam dados!")
            return []  # Retorna vazio se não conseguir todas as páginas
    
    # Verificar se coletou todas as páginas
    if len(todos_jsons) != total_pages:
        print(f"🚨 ERRO: Coletadas {len(todos_jsons)} páginas de {total_pages} necessárias!")
        print("💀 Dados INCOMPLETOS - não salvando arquivo!")
        return []
    
    if not os.path.exists('data'):
        os.makedirs('data')

    # Nome do arquivo baseado na data
    nome_arquivo = f'data/ibovespa_{data_portfolio}.json'

    # Salvar JSON completo
    with open(nome_arquivo, 'w', encoding='utf-8') as f:
        json.dump(todos_jsons, f, indent=2, ensure_ascii=False)
    
    print(f"🎉 Scraping COMPLETO! {len(todos_jsons)}/{total_pages} páginas coletadas")
    print(f"💾 JSON salvo em: {nome_arquivo}")
    
    return todos_jsons

# Executar
if __name__ == "__main__":
    jsons = scrape_ibovespa()
    
    if jsons:
        print(f"✅ SUCESSO: {len(jsons)} JSONs retornados")
    else:
        print("❌ FALHA: Scraping incompleto - nenhum arquivo salvo")