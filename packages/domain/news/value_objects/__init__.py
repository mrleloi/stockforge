"""BC-5 News value objects."""

from .extractor_metadata import ExtractorMetadata, ExtractorMetadataInvariantError
from .sentiment import Sentiment

__all__ = [
    "ExtractorMetadata",
    "ExtractorMetadataInvariantError",
    "Sentiment",
]
