import zipfile
import xml.etree.ElementTree as ET

def extract_text(doc_path):
    try:
        with zipfile.ZipFile(doc_path) as docx:
            xml_content = docx.read('word/document.xml')
            tree = ET.fromstring(xml_content)
            ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
            texts = tree.findall('.//w:t', namespaces=ns)
            text_lines = [t.text for t in texts if t.text]
            return '\n'.join(text_lines)
    except Exception as e:
        return f"Error: {e}"

text = extract_text(r"c:\Users\vizad\Desktop\GLUCOCHECK\componentes_glucocheck.docx")
with open(r"c:\Users\vizad\Desktop\GLUCOCHECK\extracted_text.txt", "w", encoding="utf-8") as f:
    f.write(text)
