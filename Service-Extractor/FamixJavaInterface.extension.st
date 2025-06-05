Extension { #name : 'FamixJavaInterface' }

{ #category : '*Service-Extractor' }
FamixJavaInterface >> allSubclassesAndImplementations [

	| subInterfaces result |
	result := OrderedCollection new.

	self implementations do: [ :imp |
		result add: imp implementingClass.
		result addAll: imp implementingClass subclassHierarchy ].


	subInterfaces := self subclassHierarchy.
	result addAll: subInterfaces.

	subInterfaces do: [ :i |
		i implementations do: [ :imp |
			result add: imp implementingClass.
			result addAll: imp implementingClass subclassHierarchy ] ].
	^ result
]
