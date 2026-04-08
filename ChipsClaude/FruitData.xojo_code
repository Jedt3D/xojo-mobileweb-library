#tag Module
Protected Module FruitData
	#tag Method, Flags = &h0
		Function AllFruits() As String()
		  Return Array("Apple", "Banana", "Cherry", "Dragonfruit", "Elderberry", "Fig", "Grape", "Honeydew", "Jackfruit", "Kiwi", "Lemon", "Mango", "Nectarine", "Orange", "Papaya", "Quince", "Raspberry", "Strawberry", "Tangerine", "Ugli Fruit", "Watermelon", "Yuzu")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RandomFruits(count As Integer) As String()
		  Var pool() As String = AllFruits()
		  Var result() As String
		  For i As Integer = 1 To count
		    If pool.Count = 0 Then Exit
		    Var idx As Integer = Floor(Rnd * pool.Count)
		    result.Add(pool(idx))
		    pool.RemoveAt(idx)
		  Next
		  Return result
		End Function
	#tag EndMethod
End Module
#tag EndModule
