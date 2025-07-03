Class {
	#name : 'MiMoveToMonolithMenuItem',
	#superclass : 'MiServiceExtractorNodeMenuItem',
	#category : 'Service-Extractor-Browser',
	#package : 'Service-Extractor',
	#tag : 'Browser'
}

{ #category : 'testing' }
MiMoveToMonolithMenuItem >> canBeExecuted [

	^ shape isShape and: [
		  shape isNode and: [
			  shape model notNil and: [ shape model rawModel notNil ] ] ]
]

{ #category : 'testing' }
MiMoveToMonolithMenuItem >> execute [

	visualization moveClassToMonolith: shape model
]

{ #category : 'testing' }
MiMoveToMonolithMenuItem >> label [
	^ 'Move class to monolith'
]
