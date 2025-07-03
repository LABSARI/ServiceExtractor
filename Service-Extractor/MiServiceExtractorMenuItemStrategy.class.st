Class {
	#name : 'MiServiceExtractorMenuItemStrategy',
	#superclass : 'HDefaultMenuItemStrategy',
	#category : 'Service-Extractor-Browser',
	#package : 'Service-Extractor',
	#tag : 'Browser'
}

{ #category : 'public' }
MiServiceExtractorMenuItemStrategy >> menuItemClassesFor: aShape [

	| clazz |
	clazz := self classFor: aShape.
	^ MiServiceExtractorNodeMenuItem subclasses , clazz subclasses
]
