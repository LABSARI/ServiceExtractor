Extension { #name : 'FamixJavaInterface' }

{ #category : '*Service-Extractor' }
FamixJavaInterface >> allSubclassesAndImplementations [

	| subclasses result |
	result := OrderedCollection new.

	self implementations do: [ :imp |
		result add: imp implementingClass.
		result addAll: imp implementingClass subclassHierarchy ].


	subclasses := self subclassHierarchy.
	result addAll: subclasses.

	subclasses do: [ :i |
		i implementations do: [ :imp |
			result add: imp implementingClass.
			result addAll: imp implementingClass subclassHierarchy ] ].
	^ result
]
