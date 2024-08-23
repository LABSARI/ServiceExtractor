Extension { #name : 'FamixJavaMethod' }

{ #category : '*Service-Extractor' }
FamixJavaMethod >> callGraphLabel [

	^ self mooseNameWithDots
]

{ #category : '*Service-Extractor' }
FamixJavaMethod >> hasReturnObjectType [
	
	
	^ self declaredType isNotNil and: [self declaredType isPrimitiveType not]
]

{ #category : '*Service-Extractor' }
FamixJavaMethod >> returnCallGraphLabel [

	^ self callGraphLabel, '.return'
]
