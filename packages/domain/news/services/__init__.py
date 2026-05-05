"""BC-5 News domain services."""

from .claim_extraction_service import ClaimExtractionService, LlmExtractorProtocol

__all__ = ["ClaimExtractionService", "LlmExtractorProtocol"]
