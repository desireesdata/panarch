from __future__ import annotations

import re
import unicodedata
from collections import Counter
from dataclasses import dataclass, field


DESCRIPTIONS = [
    "Jugements civils",
    "Jugements civils ; manquant 1857",
    "Jugements civils de simple police",
    "Jugement civil",
    "Minutes de jugements civils",
    "Jugements correctionnels",
]


STOP_WORDS = {
    "de",
    "du",
    "des",
    "la",
    "le",
    "les",
    "un",
    "une",
    "et",
    "en",
    "pour",
}


# Certains mots sont plus structurants que d'autres.
# Une valeur élevée les favorise comme nœuds de la hiérarchie.
TOKEN_PRIORITY = {
    "jugement": 100,
    "minute": 80,
    "civil": 60,
    "correctionnel": 60,
    "police": 50,
    "simple": 20,
    "manquant": 10,
}


@dataclass
class Description:
    original: str
    tokens: tuple[str, ...]


@dataclass
class Node:
    label: str
    children: list["Node"] = field(default_factory=list)
    descriptions: list[str] = field(default_factory=list)


def remove_accents(text: str) -> str:
    decomposed = unicodedata.normalize("NFKD", text)

    return "".join(
        character
        for character in decomposed
        if not unicodedata.combining(character)
    )


def simple_lemma(token: str) -> str:
    if token.isdigit():
        return token

    # Quelques traitements suffisants pour la démonstration.
    exceptions = {
        "civils": "civil",
        "civiles": "civil",
        "jugements": "jugement",
        "minutes": "minute",
        "correctionnels": "correctionnel",
    }

    if token in exceptions:
        return exceptions[token]

    if len(token) > 4 and token.endswith("s"):
        return token[:-1]

    return token


def tokenize(text: str) -> tuple[str, ...]:
    normalized = remove_accents(text.casefold())
    raw_tokens = re.findall(r"[a-z]+|\d{4}", normalized)

    return tuple(
        simple_lemma(token)
        for token in raw_tokens
        if token not in STOP_WORDS
    )


def choose_pivot(
    descriptions: list[Description],
    already_used: frozenset[str],
) -> str | None:
    """
    Choisit le meilleur token pour créer le prochain niveau.

    Le token doit apparaître dans au moins deux descriptions.
    Le score tient compte :
      - du nombre de descriptions couvertes ;
      - de la priorité métier du token.
    """
    frequencies = Counter(
        token
        for description in descriptions
        for token in set(description.tokens)
        if token not in already_used
        and not token.isdigit()
        and token not in {"manquant", "simple"}
    )

    candidates = [
        token
        for token, frequency in frequencies.items()
        if frequency >= 2
    ]

    if not candidates:
        return None

    return max(
        candidates,
        key=lambda token: (
            frequencies[token],
            TOKEN_PRIORITY.get(token, 0),
            len(token),
        ),
    )


def residual_label(
    description: Description,
    inherited_tokens: frozenset[str],
) -> str:
    """
    Produit le libellé restant après retrait des informations
    déjà représentées par les niveaux parents.
    """
    remaining = [
        token
        for token in description.tokens
        if token not in inherited_tokens
    ]

    if not remaining:
        return "(générique)"

    return " ".join(remaining)


def build_hierarchy(
    descriptions: list[Description],
    inherited_tokens: frozenset[str] = frozenset(),
) -> list[Node]:
    pivot = choose_pivot(descriptions, inherited_tokens)

    if pivot is None:
        return [
            Node(
                label=residual_label(
                    description,
                    inherited_tokens,
                ),
                descriptions=[description.original],
            )
            for description in descriptions
        ]

    with_pivot = [
        description
        for description in descriptions
        if pivot in description.tokens
    ]

    without_pivot = [
        description
        for description in descriptions
        if pivot not in description.tokens
    ]

    pivot_node = Node(
        label=pivot,
        children=build_hierarchy(
            with_pivot,
            inherited_tokens | {pivot},
        ),
    )

    result = [pivot_node]

    # Les descriptions non couvertes par ce concept restent
    # au même niveau.
    if without_pivot:
        result.extend(
            build_hierarchy(
                without_pivot,
                inherited_tokens,
            )
        )

    return result


def simplify(node: Node) -> Node:
    """
    Supprime quelques niveaux artificiels.

    Exemple :
        civil
          └── (générique)

    devient simplement :
        civil
    """
    node.children = [simplify(child) for child in node.children]

    generic_children = [
        child
        for child in node.children
        if child.label == "(générique)"
    ]

    other_children = [
        child
        for child in node.children
        if child.label != "(générique)"
    ]

    for child in generic_children:
        node.descriptions.extend(child.descriptions)

    node.children = other_children
    return node


def display_tree(
    nodes: list[Node],
    prefix: str = "",
) -> None:
    for index, node in enumerate(nodes):
        is_last = index == len(nodes) - 1
        connector = "└── " if is_last else "├── "

        print(prefix + connector + node.label)

        child_prefix = prefix + (
            "    " if is_last else "│   "
        )

        display_tree(node.children, child_prefix)

        for description in node.descriptions:
            print(
                child_prefix
                + "· "
                + repr(description)
            )


def main() -> None:
    prepared = [
        Description(
            original=text,
            tokens=tokenize(text),
        )
        for text in DESCRIPTIONS
    ]

    hierarchy = [
        simplify(node)
        for node in build_hierarchy(prepared)
    ]

    print("Descriptions hiérarchisées")
    display_tree(hierarchy)


if __name__ == "__main__":
    main()