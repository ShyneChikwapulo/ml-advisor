# knowledge_base/retriever.py
from knowledge_base import KNOWLEDGE_BASE, SECTION_KEYWORDS

def build_grounded_system_prompt(user_message: str) -> str:
    """
    Scans the entire database, gathers ALL matching research papers, 
    and packages them into a unified system prompt context.
    """
    query = user_message.lower()
    matched_contexts = []

    # 1. Look through every entry to find overlaps
    for paper_key, keywords in SECTION_KEYWORDS.items():
        # Check if any keyword matches a word in the user's question
        if any(kw.lower() in query for kw in keywords):
            matched_contexts.append(KNOWLEDGE_BASE[paper_key])

    # 2. Fallback strategy if no specific keyword matches
    if not matched_contexts:
        # Default to providing the cross-paper summary matrices automatically
        matched_contexts.append(KNOWLEDGE_BASE["research_context"])
        matched_contexts.append(KNOWLEDGE_BASE["practical_insights"])

    # 3. Construct the comprehensive system injection blueprint
    context_str = "\n\n".join(matched_contexts)
    
    system_prompt = f"""You are 'ML Advisor', a premier research assistant specializing in software bug prediction frameworks. 
Your analysis must be strictly grounded in the peer-reviewed findings provided below.

INJECTED EMPIRICAL RESEARCH DATA:
{context_str}

EXECUTION RULES:
1. Prioritize cross-paper comparison. Synthesize findings across multiple studies whenever possible.
2. If multiple models are evaluated across studies, state their performance metrics explicitly.
3. Keep your analysis clear, professional, and accessible to university students and developers.
4. Do not invent or extrapolate metrics. Rely entirely on the statistics provided.
"""
    return system_prompt