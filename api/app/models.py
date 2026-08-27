"""Request and response bodies. These also produce the OpenAPI schema."""
from typing import Literal, Optional

from pydantic import BaseModel, Field

CaptureStatus = Literal['new', 'in-progress', 'complete']
CapturePriority = Literal['low', 'normal', 'high']


class CaptureCreate(BaseModel):
    title: str = Field(min_length=1, max_length=400)
    reference: str = Field(default="", max_length=200)
    status: CaptureStatus = 'new'
    priority: CapturePriority = 'normal'


class CaptureUpdate(BaseModel):
    title: Optional[str] = Field(default=None, min_length=1, max_length=400)
    reference: Optional[str] = Field(default=None, max_length=200)
    status: Optional[CaptureStatus] = None
    priority: Optional[CapturePriority] = None


class Capture(CaptureCreate):
    id: int
