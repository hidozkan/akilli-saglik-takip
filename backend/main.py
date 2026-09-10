from fastapi import FastAPI
from pydantic import BaseModel
from openai import OpenAI
from dotenv import load_dotenv
import os

load_dotenv()

app = FastAPI()

api_key = os.getenv("OPENAI_API_KEY")

class ChatRequest(BaseModel):
    soru: str
    nabiz: int | None = None
    tansiyon: str | None = None


def rag_bilgisi_getir(soru: str) -> str:
    try:
        with open("rag_data.txt", "r", encoding="utf-8") as file:
            satirlar = file.readlines()
    except FileNotFoundError:
        return "rag_data.txt dosyası bulunamadı."

    soru_lower = soru.lower()
    ilgili_satirlar = []

    for satir in satirlar:
        satir_lower = satir.lower()

        if "nabız" in soru_lower and "nabız" in satir_lower:
            ilgili_satirlar.append(satir.strip())

        if "tansiyon" in soru_lower and "tansiyon" in satir_lower:
            ilgili_satirlar.append(satir.strip())

        if "risk" in soru_lower and ("risk" in satir_lower or "doktor" in satir_lower):
            ilgili_satirlar.append(satir.strip())

        if "acil" in soru_lower and ("acil" in satir_lower or "göğüs" in satir_lower):
            ilgili_satirlar.append(satir.strip())

    if not ilgili_satirlar:
        ilgili_satirlar = [s.strip() for s in satirlar[:12]]

    return "\n".join(ilgili_satirlar)


@app.get("/")
def home():
    return {"mesaj": "Backend çalışıyor."}


@app.post("/chat")
def chat(request: ChatRequest):
    try:
        if not api_key:
            return {
                "cevap": "Backend tarafında OPENAI_API_KEY bulunamadı. .env dosyasını kontrol et."
            }

        client = OpenAI(api_key=api_key)

        bilgi = rag_bilgisi_getir(request.soru)

        kullanici_verisi = f"""
Kullanıcının son ölçüm bilgileri:
Nabız: {request.nabiz if request.nabiz is not None else "Bilinmiyor"}
Tansiyon: {request.tansiyon if request.tansiyon is not None else "Bilinmiyor"}
"""

        prompt = f"""
Sen bir sağlık takip uygulamasındaki AI sağlık asistanısın.

Kurallar:
- Tıbbi teşhis koyma.
- İlaç önerme.
- Kullanıcıyı panikletme.
- Ciddi belirtiler varsa acil sağlık desteği öner.
- Kısa, anlaşılır ve Türkçe cevap ver.
- Verdiğin cevap sağlık bilgilendirmesidir, doktor değerlendirmesi yerine geçmez.

RAG bilgi kaynağı:
{bilgi}

{kullanici_verisi}

Kullanıcı sorusu:
{request.soru}
"""

        response = client.responses.create(
            model="gpt-4.1-mini",
            input=prompt,
        )

        return {"cevap": response.output_text}

    except Exception as e:
        return {
            "cevap": f"Backend hata aldı: {str(e)}"
        }