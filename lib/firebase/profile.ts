'use client'
import { doc, setDoc, serverTimestamp } from 'firebase/firestore'
import { User } from 'firebase/auth'
import { db } from './client'

export async function ensureUserProfile(user: User) {
  await setDoc(doc(db, 'users', user.uid), {
    uid: user.uid,
    email: user.email ?? '',
    displayName: user.displayName ?? '',
    photoURL: user.photoURL ?? '',
    updatedAt: serverTimestamp(),
  }, { merge: true })
}